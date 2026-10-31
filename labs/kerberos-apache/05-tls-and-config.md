# Lab 05 — Verify TLS and reload configuration safely

**Time:** 40–60 min · **Goal:** Validate the certificate name and recover from an invalid Apache edit.

## Concept

Kerberos authenticates an identity; HTTPS protects the web exchange and verifies the server name through a trusted certificate. This project explicitly trusts one disposable self-signed certificate. Apache's syntax check catches configuration errors before a graceful reload.

## Hands-on

```bash
docker compose exec web openssl x509 -in /run/tls/web.crt -noout -subject -dates -ext subjectAltName
docker compose exec client curl --fail https://web.lab.test/healthz
docker compose exec client curl -I https://public.lab.test/
```

Find both DNS names in the certificate and `X-Content-Type-Options: nosniff` in the response. Demonstrate the role of explicit trust by removing the trust-file environment variable for just one request:

```bash
docker compose exec client env -u CURL_CA_BUNDLE curl https://web.lab.test/healthz
```

Expect a certificate verification error. Do not change global trust or bypass checks to fix it; repeat the normal command, which uses the configured trust file.

Back up the Apache configuration, introduce one invalid directive, and test it:

```bash
mkdir -p .local
cp apache/config/site.conf .local/site.conf.backup
printf '\nInvalidLabDirective On\n' >> apache/config/site.conf
docker compose exec web apache2ctl -t
docker compose exec client curl --fail https://web.lab.test/healthz
```

Expect the syntax check to fail while the running process still serves `ok`. Restore before restarting or reloading:

```bash
cp .local/site.conf.backup apache/config/site.conf
docker compose exec web apache2ctl -t && docker compose exec web apache2ctl -k graceful
bash scripts/smoke-test.sh
```

## Checkpoint

Record the invalid-directive error and passing post-restore check. Explain why a syntax test is necessary but does not prove that a valid-looking authorization rule grants access to the correct users; that needs request tests.

**Extension:** Change the `nosniff` header's configuration only long enough to observe the response after a valid reload, then restore it and rerun the smoke test.

**Next:** [06 — Negotiate SSO](06-negotiate-sso.md).
