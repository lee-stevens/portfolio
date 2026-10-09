# Pipeline

CI/CD for the portfolio site: GitHub builds and pushes an image, a
self-hosted runner on Unraid pulls it back down and restarts the
container. See the root [README's Deployment section](../README.md#deployment)
for the high-level flow; this doc covers the pieces that live in this
directory and how to set them up or recover them.

## Files

| File | Runs where | Purpose |
|---|---|---|
| `runner.Dockerfile` | Unraid | Official `ghcr.io/actions/actions-runner` base + Docker CLI/Compose plugin + `entrypoint.sh` |
| `entrypoint.sh` | Inside the runner container | Fetches a registration token via the GitHub API, `config.sh`, `run.sh`, deregisters on exit |
| `runner-compose.yml` | Unraid | Builds/runs the runner container, separate lifecycle from the app |
| `.env.example` | — | Template for `pipeline/.env` (never committed - holds the runner's PAT) |
| `deploy.sh` | Unraid (manual) | Same steps as the workflow's `deploy` job, for a manual fallback deploy |

The actual build/push/deploy logic lives in
[`.github/workflows/build-and-deploy.yml`](../.github/workflows/build-and-deploy.yml),
not here - this directory only holds what's needed to stand up the
self-hosted runner that job's `deploy` stage runs on.

This runner is scoped to this repo only (a GitHub user account, unlike an
organization, can't register one runner across multiple repos) - it's a
separate container from the athena-toolkit runner, even though both can
run on the same Unraid box.

## Setting up the runner (fresh box, or after deleting it)

1. Generate a GitHub personal access token: either a **classic** PAT with
   the `repo` scope, or a **fine-grained** PAT scoped to this repo with
   **Administration: Read and write** (that's the specific permission
   GitHub's API requires to mint a runner registration token - easy to
   miss since it doesn't look runner-related).
2. On Unraid, create `/mnt/user/appdata/portfolio` as a git clone of this
   repo (`git clone https://github.com/lee-stevens/portfolio.git .`) - the
   deploy job operates directly in this real directory, not a fresh
   checkout.
3. In this directory (`pipeline/`): `cp .env.example .env` and set
   `ACCESS_TOKEN=<the PAT>`.
4. Build and start it:
   ```bash
   docker compose -f pipeline/runner-compose.yml up -d --build
   ```
5. Confirm it registered:
   ```bash
   docker logs -f portfolio-github-runner
   ```
   Look for `√ Connected to GitHub` then `Listening for Jobs`. It should
   also show as `online` under
   [Settings → Actions → Runners](https://github.com/lee-stevens/portfolio/settings/actions/runners)
   with labels `self-hosted, unraid-portfolio` (the workflow's `deploy`
   job targets `runs-on: [self-hosted, unraid-portfolio]` specifically).

Using the **PAT** (not the one-time token GitHub's web UI shows on that
runners page) matters: `entrypoint.sh` fetches a fresh registration token
itself on every container start using the PAT, so the runner keeps
re-registering correctly across restarts. A one-time token from the web
UI expires in about an hour and would break on the next restart.

## Known gotchas (carried over from athena-toolkit, documented so they don't recur here too)

- **`.sh` files must stay LF.** Windows checkouts can silently convert
  these to CRLF, which corrupts the shebang line on checkout on *any* OS,
  including Linux (`exec: no such file or directory` despite the file
  clearly existing). The repo-root `.gitattributes` forces `*.sh` to
  `eol=lf` to prevent this.
- **The runner is a container, not the host.** The `deploy` job in the
  workflow runs directly in `/mnt/user/appdata/portfolio` (for the real
  checkout - a fresh `actions/checkout` would be an isolated clone). That
  path only exists inside the runner container because
  `runner-compose.yml` bind-mounts it in explicitly; it is not
  automatically visible just because the container happens to run on that
  host.
- **The official runner image installs to `/home/runner`**, not
  `/actions-runner` (that path is specific to the `myoung34/github-runner`
  community wrapper, not the official image this uses).
