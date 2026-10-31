# Lab 02 — Create and inspect principals

**Time:** 30–45 min · **Goal:** Distinguish user identities from service identities and administer a disposable user.

## Concept

`alice@LAB.TEST` identifies a user; `HTTP/web.lab.test@LAB.TEST` identifies a service. The HTTP service name is case-sensitive. `kadmin.local` accesses the local KDC database through container administrator access; it does not demonstrate remote administrative authentication.

## Hands-on

```bash
docker compose exec kdc kadmin.local -q 'getprinc alice@LAB.TEST'
docker compose exec kdc kadmin.local -q 'getprinc HTTP/web.lab.test@LAB.TEST'
docker compose exec kdc kadmin.local -q 'addprinc +requires_preauth -allow_svr carol@LAB.TEST'
```

Choose a new disposable password at Carol's prompt. `+requires_preauth` requires proof before ticket issuance; `-allow_svr` prevents issuing service tickets *to* this user principal. It does not prevent the user from logging in and requesting tickets to Apache.

```bash
docker compose exec client kdestroy
docker compose exec client kinit carol@LAB.TEST
docker compose exec client klist
docker compose exec kdc kadmin.local -q 'getprinc carol@LAB.TEST'
```

If no cache exists yet, `kdestroy` can report that there is nothing to destroy; continue. Confirm that the default principal is Carol and the cache includes `krbtgt/LAB.TEST@LAB.TEST`.

Destroy the cache, then run `kinit carol@LAB.TEST` with an incorrect password. Expect failure. `docker compose exec client klist -s` must return a nonzero exit status after that failed fresh login. Obtain a valid ticket again and finish with `docker compose exec client kdestroy`.

## Checkpoint

Save the principal names, flags, and the successful/failed command exit statuses. Explain why creating a Kerberos principal does not create a Linux account in either container.

**Extension:** Change Carol's disposable password with `docker compose exec kdc kadmin.local -q 'cpw carol@LAB.TEST'`. After destroying the cache, verify that the old password fails and the new one works. Later labs use Alice/Bob and do not depend on Carol.

**Next:** [03 — Ticket lifecycle](03-ticket-lifecycle.md).
