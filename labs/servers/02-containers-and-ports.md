# Lesson 02 — Processes, containers, networks and ports

**Time:** 30–45 min · **Goal:** Distinguish an image, a running container, an internal port, and a published host port.

## Concept

An **image** packages the executable and files; a **container** runs processes using that image. Compose defines multiple services and a private network. `expose: "80"` documents Apache's internal listening port; it does **not** publish it to the host. The Nginx mapping `127.0.0.1:8080:80` connects a host loopback port to port 80 inside the container.

## Hands-on

```bash
docker compose ps
docker compose config
docker compose images
docker compose port nginx 80
docker compose exec nginx nginx -v
docker compose exec apache httpd -v
```

Inspect `compose.yaml` and find `build`, `image`, `ports`, `expose`, `volumes`, and `depends_on`. Explain which settings describe how to build a service, which control connectivity, and which share local files. Compare from inside the gateway:

```bash
docker compose exec nginx wget -q -O - http://apache:80/
curl -i http://127.0.0.1:8080/apache/
```

The hostname `apache` resolves via Compose's network DNS **inside** the project. It is not a name your host browser can normally resolve. Neither `http://127.0.0.1:80` nor `http://127.0.0.1:8080` goes directly to Apache.

## Checkpoint

Create a two-row inventory for Apache and Nginx: image/build source, container port, host port if any, and how peers reach it. Explain why binding to loopback is safer than publishing the lab on every network interface.

**Investigation:** Run `docker compose logs --tail=20 nginx`. Which process writes the logs? Do not change the host bindings just to test access from another device.

**Next:** [03 — Apache and immutable content](03-apache-static-site.md).
