#!/bin/bash
# Explicit, transparent replacement for a community wrapper's entrypoint:
# fetch a registration token via the GitHub API, configure, run, and
# deregister on exit. Nothing hidden - if this fails, the error is real.
set -euo pipefail

: "${REPO_URL:?REPO_URL is required}"
: "${ACCESS_TOKEN:?ACCESS_TOKEN is required}"
: "${RUNNER_NAME:=unraid}"
: "${LABELS:=self-hosted,unraid}"

REPO_PATH="${REPO_URL#https://github.com/}"
API="https://api.github.com/repos/${REPO_PATH}/actions/runners"
AUTH_HEADER="Authorization: token ${ACCESS_TOKEN}"
ACCEPT_HEADER="Accept: application/vnd.github+json"

cd /home/runner

cleanup() {
    echo "Deregistering runner..."
    REMOVE_TOKEN=$(curl -sf -X POST -H "${AUTH_HEADER}" -H "${ACCEPT_HEADER}" "${API}/remove-token" | jq -r .token)
    ./config.sh remove --token "${REMOVE_TOKEN}" || true
}
trap cleanup EXIT

echo "Obtaining registration token..."
REG_TOKEN=$(curl -sf -X POST -H "${AUTH_HEADER}" -H "${ACCEPT_HEADER}" "${API}/registration-token" | jq -r .token)

echo "Configuring runner..."
./config.sh --url "${REPO_URL}" --token "${REG_TOKEN}" --name "${RUNNER_NAME}" --labels "${LABELS}" --unattended --replace

echo "Starting runner..."
./run.sh
