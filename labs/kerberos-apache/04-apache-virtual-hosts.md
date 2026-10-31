# Lab 04 — Operate Apache virtual hosts and document roots

**Time:** 40–60 min · **Goal:** Serve two names from one Apache listener and make a controlled content change.

## Concept

Apache virtual hosts select configuration for a requested hostname. Both lab names resolve to one container, while each has its own document root. TLS also uses the requested name through SNI; changing only the HTTP `Host` header does not reproduce every aspect of an HTTPS request.

## Hands-on

```bash
docker compose exec web apache2ctl -S
docker compose exec web apache2ctl -M
docker compose exec client curl --fail https://web.lab.test/
docker compose exec client curl --fail https://public.lab.test/
```

Locate `ssl_module`, `auth_gssapi_module`, and the virtual hosts on port 443. Compare `ServerName` and `DocumentRoot` in `apache/config/site.conf` with the returned page titles.

Create `apache/site/public/about.html` containing a heading of your choice. It is a host file mounted into the running server; no image rebuild is needed:

```bash
docker compose exec client curl --fail https://public.lab.test/about.html
docker compose exec client curl -s -o /dev/null -w '%{http_code}\n' https://web.lab.test/about.html
docker compose exec client curl -s -o /dev/null -w '%{http_code}\n' https://public.lab.test/missing.html
```

Expected: your new page is served on the public host, and both subsequent requests return `404`. The same path can resolve differently under different document roots.

Create an empty `apache/site/public/empty/` directory and request `https://public.lab.test/empty/`. Expect `403`, because directory listing is disabled and there is no index file. Remove the temporary page and empty directory when done.

## Checkpoint

Explain which files are copied into images and which are mounted at runtime. Show that public content is separate from `/private/` and `/admin/` under the main host, and identify which virtual host is the default for unmatched names.

**Extension:** Change a public heading and fetch it again. Compare the immediate result with the image-rebuild exercise in [server Lesson 03](../servers/03-apache-static-site.md).

**Next:** [05 — TLS and safe configuration](05-tls-and-config.md).
