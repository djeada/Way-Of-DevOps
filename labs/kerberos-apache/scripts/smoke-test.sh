#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

docker compose config --quiet
docker compose exec -T web apache2ctl -t
docker compose exec -T --user www-data web test -r /run/keytabs/http.keytab
docker compose exec -T client sh -eu <<'CLIENT'
cleanup() {
    kdestroy >/dev/null 2>&1 || :
    rm -f /tmp/lab-headers /tmp/lab-body /tmp/lab-kinit-error
}
trap cleanup EXIT
cleanup

expect_status() {
    expected=$1
    shift
    actual=$(curl --noproxy '*' --silent --show-error --max-time 15 \
        --output /tmp/lab-body --write-out '%{http_code}' "$@")
    if [ "$actual" != "$expected" ]; then
        echo "Expected HTTP $expected, got $actual" >&2
        exit 1
    fi
}

curl --version | grep -q 'SPNEGO'
expect_status 200 https://web.lab.test/healthz
grep -qx ok /tmp/lab-body
expect_status 200 https://public.lab.test/
grep -q 'Public virtual host' /tmp/lab-body
expect_status 401 --dump-header /tmp/lab-headers https://web.lab.test/private/
grep -qi '^WWW-Authenticate: Negotiate' /tmp/lab-headers

if printf '%s\n' 'incorrect-lab-password' | kinit alice@LAB.TEST > /tmp/lab-kinit-error 2>&1; then
    echo 'Incorrect password unexpectedly accepted' >&2
    exit 1
fi
printf '%s\n' 'Alice-lab-only!' | kinit alice@LAB.TEST
klist -s
kvno HTTP/web.lab.test@LAB.TEST
klist | grep -q 'HTTP/web.lab.test@LAB.TEST'
expect_status 200 --negotiate -u : https://web.lab.test/private/
grep -q 'Private lab page' /tmp/lab-body
expect_status 200 --negotiate -u : https://web.lab.test/admin/
grep -q 'Admin lab page' /tmp/lab-body
if kvno HTTP/missing.lab.test@LAB.TEST >/dev/null 2>&1; then
    echo 'Unregistered service unexpectedly accepted' >&2
    exit 1
fi

kdestroy
printf '%s\n' 'Bob-lab-only!' | kinit bob@LAB.TEST
expect_status 200 --negotiate -u : https://web.lab.test/private/
expect_status 403 --negotiate -u : https://web.lab.test/admin/
kdestroy
if klist -s; then
    echo 'Credential cache unexpectedly survived kdestroy' >&2
    exit 1
fi
expect_status 401 https://web.lab.test/private/
echo 'PASS: TLS, virtual hosts, tickets, SSO, authorization, and logout'
CLIENT
