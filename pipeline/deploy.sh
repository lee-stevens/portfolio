#!/bin/bash
# Manual fallback for the deploy step build-and-deploy.yml normally runs on
# the self-hosted runner. Run `docker login ghcr.io` first if you haven't.
set -e

# Always run from repo root
cd "$(dirname "$0")/.."

echo "🔄 Pulling latest image from GHCR..."
docker compose pull

echo "🚀 Restarting service..."
docker compose up -d

echo "✅ Deployment complete!"
docker compose ps
