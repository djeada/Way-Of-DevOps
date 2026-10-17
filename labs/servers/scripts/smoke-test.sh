#!/usr/bin/env bash
set -euo pipefail

base="${BASE_URL:-http://127.0.0.1:8080}"
echo "Checking $base"
curl --fail --silent --show-error "$base/healthz" | grep -qx "ok"
curl --fail --silent --show-error "$base/" | grep -q "Nginx demo"
curl --fail --silent --show-error "$base/apache/" | grep -q "Apache demo"
curl --fail --silent --show-error "$base/apache/about.html" | grep -q "What Apache does"
curl --silent --show-error -I "$base/" | grep -qi '^x-content-type-options: nosniff'
code="$(curl --silent --show-error --output /dev/null --write-out '%{http_code}' "$base/missing-page")"
test "$code" = "404"
echo "PASS: gateway, upstream, response headers, and 404 handling"
