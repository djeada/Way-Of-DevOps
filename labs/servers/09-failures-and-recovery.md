# Lesson 09 — Diagnose a failure and restore service

**Time:** 40–60 min · **Goal:** Identify a broken dependency using status codes and logs, then restore the service safely.

## Concept

An upstream timeout or refused connection may surface as `502 Bad Gateway` (or another gateway error) from Nginx. A healthy gateway process does not imply that its dependencies are healthy. Recovery should use observable checks and a written procedure, not guessing.

## Hands-on

First establish a healthy baseline:

```bash
./scripts/smoke-test.sh
docker compose ps
```

Intentionally stop **only** the disposable Apache service:

```bash
docker compose stop apache
curl -i http://127.0.0.1:8080/healthz
curl -i http://127.0.0.1:8080/
curl -i http://127.0.0.1:8080/apache/
docker compose logs --tail=30 nginx
docker compose ps
```

Observe: Nginx's own page and `/healthz` can still return `200`, but `/apache/` should return `502` while the upstream is down. The proxy error log should indicate an upstream connection problem.

Restore and confirm:

```bash
docker compose start apache
docker compose ps
./scripts/smoke-test.sh
```

If the startup check is still pending, inspect `docker compose logs apache` and retry when Apache reports healthy.

## Checkpoint

Write a concise runbook: **symptom**, **impact**, **first checks**, **likely cause**, **recovery command**, and **verification**. Explain the difference between temporarily restoring a container and fixing a persistent configuration error. Note how the smoke test catches a dependency failure that `/healthz` alone misses.

**Next:** [10 — Capstone and operations runbook](10-capstone.md).
