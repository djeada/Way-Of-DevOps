# Lesson 08 — Logs, health and observability

**Time:** 35–50 min · **Goal:** Use a request and the container logs to answer what happened.

## Concept

**Access logs** record requests and their HTTP results. **Error logs** explain some failures. **Health checks** answer a narrower question: is a particular component responding as expected? Our `/healthz` checks **Nginx only**, not whether Apache can serve requests. A gateway can be alive while one upstream is unavailable.

## Hands-on

```bash
curl -i http://127.0.0.1:8080/
curl -i http://127.0.0.1:8080/apache/about.html
curl -i http://127.0.0.1:8080/missing-file
docker compose logs --tail=50 nginx
docker compose logs --tail=50 apache
docker compose ps
curl -i http://127.0.0.1:8080/healthz
```

Find the `200` and `404` requests in the Nginx logs. Read the `healthcheck` blocks in `compose.yaml`: Nginx fetches `/healthz` and Apache fetches its local homepage and searches for "Apache demo". A status of `healthy` does not mean an application is safe, fast, or correctly configured.

## Checkpoint

Write an incident note with the request URL, status, approximate timestamp, corresponding log line, and what each health check measures. Answer: can the gateway be healthy but `/apache/` fail? Verify in Lesson 09.

**Extension:** Propose useful production signals: error-rate by route, p95 latency, upstream saturation, and alerts linked to service objectives. Logs alone are not a full observability platform.

**Next:** [09 — Failures and recovery](09-failures-and-recovery.md).
