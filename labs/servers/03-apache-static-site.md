# Lesson 03 — Build a static site with Apache httpd

**Time:** 40–60 min · **Goal:** Understand the document root, image build context, and immutable deployment artifacts.

## Concept

Apache httpd serves files from a **document root**. The Dockerfile in `apache/Dockerfile` starts from the official `httpd:2.4-alpine` image family and copies `apache/site/` into `/usr/local/apache2/htdocs/`. The site becomes part of the image: editing a file on your host does not update an already running Apache container until you rebuild and recreate it.

## Hands-on

```bash
cat apache/Dockerfile
docker compose exec apache httpd -t
curl -i http://127.0.0.1:8080/apache/
curl -i http://127.0.0.1:8080/apache/about.html
curl -i http://127.0.0.1:8080/apache/contact.html
```

Edit the text within `apache/site/about.html`, save the file, and request the page again. You should still see the old version. Rebuild and recreate **only Apache**:

```bash
docker compose up -d --build apache
docker compose ps
curl http://127.0.0.1:8080/apache/about.html
```

You should now see the new text. If Nginx briefly returns `502` while the Apache container restarts, retry once Apache is healthy.

## Checkpoint

Explain what `COPY` does at build time, why `docker compose restart apache` alone would not pick up an image content change, and why an image can be promoted consistently between environments. Identify the four original website assets now maintained under `apache/site/`.

**Extension:** Add a fourth simple page and link to it with a relative URL. Confirm that it works below the proxy's `/apache/` path.

**Next:** [04 — Nginx static hosting and routing](04-nginx-static-routing.md).
