# Lab 03 — Obtain, renew, and destroy tickets

**Time:** 30–45 min · **Goal:** Observe the difference between a ticket-granting ticket and an application service ticket.

## Concept

`kinit` obtains a ticket-granting ticket (TGT). A client uses it to request a ticket for a particular service. A credential cache stores these tickets; a keytab stores long-term keys. Keep both out of Git and recordings.

## Hands-on

Use Alice's password from the [setup](README.md#first-run):

```bash
docker compose exec client kinit -r 8h alice@LAB.TEST
docker compose exec client klist -ef
docker compose exec client kvno HTTP/web.lab.test@LAB.TEST
docker compose exec client klist -ef
docker compose exec client kinit -R
docker compose exec client klist -f
```

Compare the service-principal lists before/after `kvno`. Locate the renewable flag, expiry, and renew-until time. A renewal remains limited by realm/principal policy and the renew-until time; it is not an unlimited session.

Observe a short-lived TGT in an isolated cache, preserving the default cache:

```bash
docker compose exec client kinit -c FILE:/tmp/short.ccache -l 30s alice@LAB.TEST
docker compose exec client klist -c FILE:/tmp/short.ccache
```

After the displayed expiry (wait about 35 seconds), run:

```bash
docker compose exec client klist -s -c FILE:/tmp/short.ccache
docker compose exec client kdestroy -c FILE:/tmp/short.ccache
docker compose exec client kdestroy
docker compose exec client klist -s
```

Both validity checks should return nonzero. The exact displayed times depend on when you ran the exercise. Clock-skew tolerances can affect application acceptance near expiry; use the cache validity check here, and do not change the host clock.

## Checkpoint

Explain which step contacted the KDC for a service ticket and why `kdestroy` is local cache cleanup, not a realm-wide revocation. An already copied ticket or an application's own session may remain usable until its applicable expiry.

**Extension:** Request `HTTP/missing.lab.test@LAB.TEST` with `kvno` after a fresh Alice login. Expect a service-not-found error; destroy the cache afterward.

**Next:** [04 — Apache virtual hosts](04-apache-virtual-hosts.md).
