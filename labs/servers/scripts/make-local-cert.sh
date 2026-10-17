#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p certs
umask 077
openssl req -x509 -newkey rsa:2048 -sha256 -nodes -days 2 \
  -keyout certs/localhost-key.pem -out certs/localhost.pem \
  -subj "/CN=localhost" \
  -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"
echo "Generated a disposable self-signed localhost certificate in labs/servers/certs/."
echo "Use curl -k for this local exercise only; real deployments must verify certificates."
