#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

restore() {
    docker compose start kdc
    docker compose exec -T client kdestroy >/dev/null 2>&1 || :
}
trap restore EXIT

docker compose exec -T client sh -eu <<'CLIENT'
kdestroy >/dev/null 2>&1 || :
printf '%s\n' 'Alice-lab-only!' | kinit alice@LAB.TEST
kvno HTTP/web.lab.test@LAB.TEST
CLIENT

docker compose stop kdc
docker compose exec -T client sh -eu <<'CLIENT'
curl --noproxy '*' --fail --silent --show-error --max-time 15 \
    --negotiate -u : https://web.lab.test/private/ | grep -q 'Private lab page'
kdestroy
if printf '%s\n' 'Alice-lab-only!' | timeout 15 kinit alice@LAB.TEST >/dev/null 2>&1; then
    echo 'A new login unexpectedly succeeded while the KDC was stopped' >&2
    exit 1
fi
echo 'PASS: cached service ticket works; a new login needs the KDC'
CLIENT
