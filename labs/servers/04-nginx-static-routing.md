# Lesson 04 — Nginx static sites, routes and errors

**Time:** 40–55 min · **Goal:** Serve static files from a read-only mount and understand Nginx location selection.

## Concept

Nginx serves `nginx/site/index.html` directly. Unlike the Apache site, `nginx/site/` is **bind-mounted** into its container: changing the file on disk changes what the running web server reads. Content is mounted read-only so the web server cannot edit it.

The active `server` block lives in `nginx/default.conf`, and its common routing rules are in `nginx/common.inc`. The `location /` block uses `try_files` to find an actual file or return `404`.

## Hands-on

```bash
docker compose exec nginx nginx -t
docker compose exec nginx nginx -T
curl -i http://127.0.0.1:8080/
curl -i http://127.0.0.1:8080/style.css
curl -i http://127.0.0.1:8080/does-not-exist
```

Edit the paragraph in `nginx/site/index.html`. Reload your browser or `curl` request: unlike Lesson 03, no image rebuild is required. Compare the workflows and explain why a bind mount is convenient for learning but an immutable built artifact is preferable for many production releases.

Read `nginx/common.inc` and identify the special `/healthz` path, `/apache` redirect, `/apache/` proxy, and fallback `/` route.

## Checkpoint

Show successful HTML/CSS responses and a `404` for an unknown file. Describe the difference between an Nginx configuration reload and a client/browser refresh.

**Experiment:** Why would a blanket single-page-app fallback to `index.html` conceal a missing static file? This lab intentionally returns `404` instead.

**Next:** [05 — Reverse proxy and service discovery](05-reverse-proxy.md).
