# Lesson 10 — Capstone: release, verify, break, recover

**Time:** 60–90 min · **Goal:** Deliver and operate a small two-server site using a repeatable change procedure.

## Scenario

You maintain a static Nginx front end and an Apache-backed documentation area. Prepare a modest release that changes content on both servers and introduces one deliberate, reviewable Nginx configuration change. Show that you can detect a broken upstream, restore it, and hand off operational evidence.

## Tasks

1. **Baseline.** Run `docker compose up -d --build` and `./scripts/smoke-test.sh`. Record the image names, services, ports, health status, and the two request paths.
2. **Content release.** Update `nginx/site/index.html` and `apache/site/about.html` with a new paragraph explaining which component serves each page. Observe that the Nginx change appears immediately, while the Apache change requires `docker compose up -d --build apache`.
3. **Config change.** Add a new exact-match location `/course-info` to `nginx/common.inc` returning status `200` with a short plain-text response. Example:
   
   ```nginx
   location = /course-info {
       default_type text/plain;
       return 200 "Web server course\n";
   }
   ```
   
   Run `docker compose exec nginx nginx -t` *before* `docker compose exec nginx nginx -s reload`, then `curl -i http://127.0.0.1:8080/course-info`. If validation fails, fix the file before reloading.
4. **Security and transport.** Demonstrate the three configured response headers, prove only loopback host ports are published, then follow [Lesson 07](07-https-and-tls.md) to start local HTTPS. Verify `curl --cacert certs/localhost.pem -I https://localhost:8443/`. The TLS service also includes `common.inc`; reload the TLS gateway if your change was made after it started: `docker compose exec nginx-tls nginx -t` and `docker compose exec nginx-tls nginx -s reload`.
5. **Failure drill.** Stop Apache, record the working Nginx homepage and failing upstream status, then restore Apache and rerun the smoke test. Do not mistake `/healthz` for end-to-end readiness.
6. **Handoff.** Write a short runbook: start, validate, reload, smoke test, view logs, detect upstream failure, recover, and clean up. Include the exact verification outputs you saw (no credentials, private data, or generated keys).

## Acceptance checklist

- [ ] Both sites load through Nginx and unknown pages return `404`.
- [ ] An Apache content edit appears only after rebuilding; an Nginx static edit is immediate.
- [ ] New `/course-info` route works after successful `nginx -t` and reload.
- [ ] Security headers and localhost-only bindings are documented.
- [ ] HTTPS verifies with the **explicit local certificate**, not `-k`.
- [ ] Simulated upstream failure is detected and fully recovered.
- [ ] `./scripts/smoke-test.sh` passes after recovery; the runbook is understandable without verbal explanation.

## Finish and clean up

If you started the TLS overlay:

```bash
docker compose -f compose.yaml -f compose.tls.yaml down
rm -rf certs
```

Otherwise run `docker compose down`. Restore any temporary training edits you do not wish to keep. Discuss what would change on a real host: DNS, managed certificates, non-root/runtime hardening, secrets management, patching, monitoring, backups, staged deployment, and incident ownership.

**Further practice:** Implement an end-to-end readiness route that returns failure when Apache is unavailable, and write a separate automated assertion for it.
