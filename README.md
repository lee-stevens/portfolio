# portfolio

Personal portfolio site for lee-stevens.dev, built with [Astro](https://astro.build) as a static site.

## Deployment

[![Build and Deploy](https://github.com/lee-stevens/portfolio/actions/workflows/build-and-deploy.yml/badge.svg?branch=main)](https://github.com/lee-stevens/portfolio/actions/workflows/build-and-deploy.yml)

This project is self-hosted via Docker Compose on a home Unraid server — there is no cloud hosting involved.

The image is built and pushed to `ghcr.io/lee-stevens/portfolio` by [`.github/workflows/build-and-deploy.yml`](.github/workflows/build-and-deploy.yml) on every push to `main`. A self-hosted GitHub Actions runner living on the Unraid box picks up the deploy step from there — it pulls the updated image and restarts the container. See [`pipeline/README.md`](pipeline/README.md) for how that runner is set up or recovered, and `pipeline/deploy.sh` for the same steps as a manual fallback.

## Structure

- [src/pages/index.astro](src/pages/index.astro) — the whole page: hero, experience, projects, contact. Edit the `experience` and `projectCategories` arrays at the top to update content.
- [src/layouts/BaseLayout.astro](src/layouts/BaseLayout.astro) — shared `<head>` and global styles/theme.

## Commands

| Command           | Action                                          |
| :----------------- | :----------------------------------------------- |
| `npm install`       | Install dependencies                             |
| `npm run dev`        | Start local dev server at `localhost:4321`        |
| `npm run build`      | Build the static site to `./dist/`                |
| `npm run preview`    | Preview the production build locally              |

## Local Docker

```sh
docker compose up -d --build
```

Builds the site locally and serves it via nginx on `localhost:8080` (see [docker-compose.yml](docker-compose.yml) to change the port). The image is a two-stage build — Node compiles the static site, then only the `dist/` output and nginx ship in the final image.
