# Web servers: 10 hands-on DevOps lessons

Learn what a web server does, then build, operate, secure, and recover a small **two-server system**. This course replaces the former top-level `servers/` walkthroughs with reproducible exercises. It is for a local workstation, not an internet-facing deployment.

**Level:** Beginner → intermediate. **Time:** 30–60 minutes per lesson. Work through the lessons in order; they share the same environment. No cloud account or credentials are needed.

## Architecture

```text
Browser / curl
      |
      | http://127.0.0.1:8080
      v
  Nginx (gateway)
      |-- / and /healthz --> local static files / gateway health
      |
      +-- /apache/ -------> Apache httpd (internal Compose network)
                               |
                               +--> site/ (baked into a Docker image)

Optional: https://127.0.0.1:8443 --> second Nginx service
          (a self-signed localhost certificate; same content/routes)
```

Nginx is the public-facing **reverse proxy** for these local exercises; Apache is the **upstream server**. Only Nginx ports are published, and only on host loopback. A container is not a replacement for a fully managed server or VM; the course teaches transferable concepts using containers as disposable hosts.

## Prerequisites and first run

- Docker Engine or Docker Desktop with the Compose v2 plugin (`docker compose version`).
- A POSIX-style shell (bash on Linux/macOS or WSL/Git Bash on Windows), `curl`, and a text editor.
- OpenSSL for Lesson 07. Internet access is needed once to pull base images; lessons otherwise run locally.
- Host ports **8080** and, for HTTPS only, **8443** must be free.

From **this directory** (`labs/servers`):

```bash
docker compose up --build -d
docker compose ps
curl -i http://127.0.0.1:8080/healthz
curl -i http://127.0.0.1:8080/
curl -i http://127.0.0.1:8080/apache/
./scripts/smoke-test.sh
```

Expected: `/healthz` returns `200` and `ok`; `/` contains "Nginx demo"; `/apache/` contains "Apache demo"; the smoke test finishes successfully. If the first request races the startup, wait for `docker compose ps` to report healthy services and retry.

## Lesson sequence

| Lesson | Focus | Checkpoint |
|---|---|---|
| [01 — What is a web server?](01-http-request-lifecycle.md) | requests, responses, status codes, headers | explain the request path |
| [02 — Containers, ports and processes](02-containers-and-ports.md) | image, container, network, exposure | identify published vs internal ports |
| [03 — Apache and immutable content](03-apache-static-site.md) | Dockerfile, document root, image rebuilds | publish an Apache page |
| [04 — Nginx static hosting and routing](04-nginx-static-routing.md) | bind mounts, locations and 404s | make a static page change |
| [05 — Reverse proxy and DNS](05-reverse-proxy.md) | service discovery, upstreams, forwarded headers | trace a proxied request |
| [06 — Configuration and hardening](06-safe-config-and-headers.md) | syntax checks, safe reloads, response headers | verify a controlled change |
| [07 — Local HTTPS and TLS](07-https-and-tls.md) | certificates, encryption, trust | test local TLS without treating it as trusted |
| [08 — Logs and health checks](08-logs-and-health.md) | request logs, liveness vs dependencies | investigate a request |
| [09 — Failures and recovery](09-failures-and-recovery.md) | 502 errors, diagnosis and restart | restore a failed upstream |
| [10 — Capstone and runbook](10-capstone.md) | reproducible change and operations | demonstrate, test and clean up |

## Files and how changes take effect

- `compose.yaml` — the two-service local topology.
- `apache/Dockerfile` and `apache/site/` — Apache image and its static content. **Rebuild** after editing: `docker compose up -d --build apache`.
- `nginx/site/` — Nginx static content bind-mounted **read-only**, visible after saving/reloading the browser.
- `nginx/default.conf`, `nginx/common.inc` — gateway configuration, bind-mounted read-only. Check with `docker compose exec nginx nginx -t` and **reload** with `docker compose exec nginx nginx -s reload`.
- `compose.tls.yaml`, `nginx/tls.conf` and `scripts/make-local-cert.sh` — optional, separate local HTTPS listener; run only in Lesson 07 onward.
- `scripts/smoke-test.sh` — quick regression checks; not a production test suite.

**Useful commands:**

```bash
docker compose ps
docker compose logs --tail=30 nginx apache
docker compose exec nginx nginx -T
docker compose down
```

If you changed a mounted configuration and Nginx will not reload, revert the edit, run `nginx -t` again, and reload. The container's last good configuration continues serving until a valid reload.

## Safety and scope

- The Compose ports use `127.0.0.1` deliberately: **do not** change them to `0.0.0.0` for a demo on an untrusted network.
- No real secrets or production data belong here. The self-signed certificate and its **private key** are local teaching artifacts, ignored by Git; never reuse them or bypass certificate checks in production.
- Nginx/Apache images use illustrative pinned version families, **not immutable digests**. Update and scan images in real deployments.
- Headers and a read-only content mount are only *parts* of hardening. Production also requires patching, least-privilege runtime users, resource limits, managed TLS, backups, and monitoring.
- When finished, stop the project from `labs/servers` using `docker compose -f compose.yaml -f compose.tls.yaml down` if HTTPS was started, or `docker compose down` otherwise. To remove the local certificate: `rm -rf certs`.

## Related reading

[Networking and HTTP](../../notes/networking.md) · [Containers and orchestration](../../notes/containers_and_orchestration.md) · [Security and secrets](../../notes/security_and_secrets.md) · [Observability](../../notes/observability.md) · [Managing servers in a small company](../../notes/server_in_small_company.md)
