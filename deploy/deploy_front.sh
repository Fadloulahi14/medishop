#!/usr/bin/env bash
set -Eeuo pipefail
IMAGE="$1"
NAME="medishop-front"
PORT="127.0.0.1:8080:80"
OLD_IMAGE=$(docker inspect -f '{{.Config.Image}}' "$NAME" 2>/dev/null || true)
rollback() {
  echo "Échec, rollback..."
  docker rm -f "$NAME" >/dev/null 2>&1 || true
  if [[ -n "$OLD_IMAGE" ]]; then docker run -d --name "$NAME" --restart unless-stopped -p "$PORT" "$OLD_IMAGE"; fi
}
trap rollback ERR
docker pull "$IMAGE"
docker rm -f "$NAME" >/dev/null 2>&1 || true
docker run -d --name "$NAME" --restart unless-stopped -p "$PORT" "$IMAGE"
sleep 5
curl -fsS http://127.0.0.1:8080/ >/dev/null
trap - ERR
echo "Frontend déployé"
