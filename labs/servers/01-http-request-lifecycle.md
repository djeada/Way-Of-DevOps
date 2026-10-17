# Lesson 01 — What does a web server actually do?

**Time:** 30–45 min · **Goal:** Trace a request from client to server and interpret a response.

## Concept

A web server listens on a network socket, parses an HTTP request, chooses a resource, and sends a response with a **status**, **headers**, and usually a **body**. A web page can be static even when the request crosses multiple servers. A reverse proxy handles a client-facing request before passing some paths to an upstream.

In this environment, requests for `/` go to Nginx's static files; requests for `/apache/` pass through Nginx to Apache. Do not mistake the **server** (software) for the **machine** (host or container).

## Hands-on

Start in `labs/servers`:

```bash
docker compose up --build -d
curl -i http://127.0.0.1:8080/
curl -i http://127.0.0.1:8080/apache/
curl -i http://127.0.0.1:8080/healthz
curl -i http://127.0.0.1:8080/not-a-page
curl -i http://127.0.0.1:8080/apache
```

Read each status line and `Content-Type`. Notice `200`, `404`, and the `308` redirect from `/apache` to `/apache/`. Re-run a request with `curl -I` to ask for headers only:

```bash
curl -I http://127.0.0.1:8080/apache/
```

## Checkpoint

Record a small table: URL, method, status, server handling the content, and one useful header. Sketch the two request paths without copying the diagram from the course README. Explain why a redirect needs a `Location` header and why a `404` is different from a connection failure.

**Experiment:** Request a nonexistent page below `/apache/`. Which server creates that response? Check the body and logs in Lesson 08.

**Next:** [02 — Containers, ports and processes](02-containers-and-ports.md).
