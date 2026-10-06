#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fixture="$repo_root/scripts/fixtures/nginx-unavailable-upstream.conf"
image="${NGINX_TEST_IMAGE:-nginx:1.31.2-alpine3.23}"
container="geonode-nginx-liveness-${RANDOM}-$$"

cleanup() {
  docker rm -f "$container" >/dev/null 2>&1 || true
}
trap cleanup EXIT

docker run --detach --name "$container" \
  --publish 127.0.0.1::8080 \
  --volume "$fixture:/etc/nginx/conf.d/default.conf:ro" \
  "$image" >/dev/null

port="$(docker port "$container" 8080/tcp | awk -F: 'END { print $NF }')"
for _ in $(seq 1 20); do
  if timeout 1 bash -c "</dev/tcp/127.0.0.1/$port" 2>/dev/null; then
    break
  fi
  sleep 0.25
done

timeout 1 bash -c "</dev/tcp/127.0.0.1/$port"

status="$(curl --silent --output /dev/null --write-out '%{http_code}' \
  "http://127.0.0.1:$port/")"
if [[ "$status" != "502" ]]; then
  echo "Expected proxy root to return 502, got $status" >&2
  exit 1
fi

docker stop "$container" >/dev/null
if timeout 1 bash -c "</dev/tcp/127.0.0.1/$port" 2>/dev/null; then
  echo "TCP probe unexpectedly passed after nginx stopped" >&2
  exit 1
fi

echo "runtime A/B passed: upstream 502 kept TCP alive; stopped nginx failed TCP"
