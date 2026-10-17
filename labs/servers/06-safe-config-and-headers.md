# Lesson 06 — Safe configuration changes and basic hardening

**Time:** 40–60 min · **Goal:** Validate before reloading a server and reason about defense in depth.

## Concept

An operator should be able to describe a change, test its configuration, reload without losing a known-good process, and verify the result. This Compose lab demonstrates local-only port publishing, read-only web content mounts, a restricted upstream, and three simple security response headers. These choices are **not** a complete production security posture.

## Hands-on

Inspect the current headers and configuration:

```bash
curl -I http://127.0.0.1:8080/
curl -I http://127.0.0.1:8080/apache/
docker compose exec nginx nginx -t
docker compose exec nginx nginx -T
```

Find `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, and `Referrer-Policy: no-referrer`. In `nginx/common.inc`, change the `Referrer-Policy` value to `strict-origin-when-cross-origin`, then apply the standard workflow:

```bash
docker compose exec nginx nginx -t
docker compose exec nginx nginx -s reload
curl -I http://127.0.0.1:8080/
```

Check the new value. Restore `no-referrer`, validate, reload, and verify again. **Never reload a configuration that fails `nginx -t`.** Inspect `compose.yaml` for `127.0.0.1` binding, `:ro` mounts, and `no-new-privileges`; discuss what each does and does not protect.

## Checkpoint

Document: desired change → validation command → reload command → HTTP evidence → rollback. Explain why authentication, modern patch levels, appropriate runtime privileges, resource limits, and real TLS certificate management remain necessary for production.

**Investigation:** Which settings belong in an image, a mounted configuration, or a secret manager? Do not add real secrets to this repository.

**Next:** [07 — Local HTTPS and TLS](07-https-and-tls.md).
