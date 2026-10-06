#!/usr/bin/env bash
set -euo pipefail

helm_bin="${HELM_BIN:-helm}"
chart="${CHART_PATH:-charts/geonode}"
template="templates/nginx/nginx-deploy.yaml"

probe_block() {
  awk '
    /^[[:space:]]+livenessProbe:/ { capture = 1 }
    capture && /^[[:space:]]+resources:/ { exit }
    capture { print }
  '
}

default_probe="$($helm_bin template nginx-probe-default "$chart" --show-only "$template" | probe_block)"
grep -q 'tcpSocket:' <<<"$default_probe"
grep -q 'port: http' <<<"$default_probe"
if grep -q 'httpGet:' <<<"$default_probe"; then
  echo "Default nginx liveness unexpectedly contains an HTTP handler" >&2
  exit 1
fi

override_probe="$($helm_bin template nginx-probe-override "$chart" \
  --show-only "$template" \
  --values "$chart/ci/nginx-liveness-http-values.yaml" | probe_block)"
grep -q 'httpGet:' <<<"$override_probe"
grep -q 'path: /healthz' <<<"$override_probe"
if grep -q 'tcpSocket:' <<<"$override_probe"; then
  echo "Custom nginx liveness unexpectedly retained the TCP handler" >&2
  exit 1
fi

echo "nginx liveness default and custom override render correctly"
