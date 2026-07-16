#!/usr/bin/env bash
set -Eeuo pipefail
IMAGE="$1"
NAME="medishop-back"
OLD_IMAGE=$(docker inspect -f '{{.Config.Image}}' "$NAME" 2>/dev/null || true)
rollback() {
  echo "Échec, rollback..."
  docker rm -f "$NAME" >/dev/null 2>&1 || true
  if [[ -n "$OLD_IMAGE" ]]; then
    docker run -d --name "$NAME" --restart unless-stopped -p 3000:3000 \
      -e DB_HOST="$DB_HOST" -e DB_NAME="$DB_NAME" -e DB_USER="$DB_USER" -e DB_PASSWORD="$DB_PASSWORD" "$OLD_IMAGE"
  fi
}
trap rollback ERR
docker pull "$IMAGE"
docker rm -f "$NAME" >/dev/null 2>&1 || true
docker run -d --name "$NAME" --restart unless-stopped -p 3000:3000 \
  -e DB_HOST="$DB_HOST" -e DB_NAME="$DB_NAME" -e DB_USER="$DB_USER" -e DB_PASSWORD="$DB_PASSWORD" "$IMAGE"
sleep 8
curl -fsS http://127.0.0.1:3000/health >/dev/null
trap - ERR
echo "Backend déployé"
