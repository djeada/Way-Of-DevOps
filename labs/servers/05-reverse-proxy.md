# Lesson 05 — Nginx as a reverse proxy

**Time:** 45–60 min · **Goal:** Explain Docker DNS, upstream services, prefix routing, and forwarded HTTP headers.

## Concept

A **reverse proxy** receives a client's request and makes a new upstream request. Clients need not know Apache's container address. In `nginx/common.inc`, `proxy_pass http://apache:80/;` forwards the `/apache/` route to Apache after removing that prefix (the trailing slash matters).

`Host`, `X-Forwarded-For`, and `X-Forwarded-Proto` communicate some original request context. Do not blindly trust client-supplied forwarded headers in a real app; establish a trusted proxy boundary first.

## Hands-on

```bash
curl -i http://127.0.0.1:8080/apache/
curl -i http://127.0.0.1:8080/apache/about.html
curl -I http://127.0.0.1:8080/apache
docker compose exec nginx wget -q -O - http://apache:80/about.html
docker compose exec nginx nginx -t
```

Compare the browser-facing URL with the upstream path. Find the `location = /apache` redirect and the `location /apache/` block. Explain why the Apache pages use relative links (`about.html`, `styles/style.css`) instead of hard-coded absolute `/about.html` links: relative links keep the site working under the proxy's prefix.

## Checkpoint

Draw: client → published Nginx port → Docker DNS name `apache` → Apache port 80 → file. Demonstrate a link and stylesheet working under `/apache/`. Confirm that Apache is **not** published directly to a host port.

**Extension:** Explain how the design would differ for a dynamic upstream app that needs WebSocket support, trusted forwarded headers, or explicit timeouts.

**Next:** [06 — Configuration and hardening](06-safe-config-and-headers.md).
