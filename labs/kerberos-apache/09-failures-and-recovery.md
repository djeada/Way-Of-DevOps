# Lab 09 — Diagnose KDC outages and naming errors

**Time:** 40–60 min · **Goal:** Separate service availability from the ability to issue new tickets.

## Concept

A client can present an already cached, unexpired service ticket without obtaining another one. A new login needs the KDC. The lab disables Apache sessions and credential delegation so this experiment focuses on ticket caching.

## Hands-on

Start from healthy services and run the outage exercise:

```bash
docker compose up --detach --wait --wait-timeout 120
bash scripts/outage-test.sh
docker compose up --detach --wait --wait-timeout 120
bash scripts/smoke-test.sh
```

Read the script before running it. It obtains Alice's TGT and an HTTP service ticket, stops only the KDC, verifies that the private page remains accessible, destroys the cache, and checks that a fresh login fails. Its exit trap restarts the KDC even if an assertion fails; the following `up --wait` waits for actual recovery.

Compare the KDC and Apache logs. Apache health checks remain successful during the outage because `/healthz` measures the web server, not every dependency. The authenticated smoke test provides a broader check.

After recovery, obtain a fresh Alice TGT and investigate an unregistered service:

```bash
docker compose exec client kinit alice@LAB.TEST
docker compose exec client env KRB5_TRACE=/dev/stderr kvno HTTP/typo.lab.test@LAB.TEST
docker compose exec client kdestroy
```

Expect service-not-found, rather than a password error. Inspect only synthetic trace output. Relate the requested service name to the Apache hostname and the keytab principal.

## Checkpoint

Use this troubleshooting order and record one piece of evidence at each relevant layer:

| Layer | Useful check |
|---|---|
| Name/network | `getent hosts`, `docker compose ps` |
| TLS | Certificate names, trust file, curl verification error |
| Credentials | `klist -ef`, ticket expiry |
| Service identity | `kvno`, `klist -kte`, matching KVNO |
| Apache policy | `apache2ctl -t`, principal/status in access logs |

Explain why restarting Apache cannot fix a misspelled service principal or an unavailable KDC. For ticket expiry, repeat the isolated-cache experiment from [Lab 03](03-ticket-lifecycle.md); do not change the workstation clock.

**Next:** [10 — Capstone](10-capstone.md).
