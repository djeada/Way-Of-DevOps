# Lab 08 — Inspect and rotate an HTTP service key

**Time:** 45–60 min · **Goal:** Diagnose a stale service key and deploy a replacement with appropriate permissions.

## Concept

A keytab permits unattended service authentication. Its key version number (KVNO) must match the key used to encrypt a newly issued service ticket. Ordinary `ktadd` randomizes the principal's keys; exporting with `-norandkey` preserves them. Rotation therefore needs coordinated deployment.

## Hands-on

```bash
docker compose exec kdc klist -kte /keytabs/http.keytab
docker compose exec kdc kadmin.local -q 'getprinc HTTP/web.lab.test@LAB.TEST'
docker compose exec --user www-data web test -r /run/keytabs/http.keytab
docker compose exec client kinit alice@LAB.TEST
docker compose exec client kvno HTTP/web.lab.test@LAB.TEST
```

Record the principal, encryption types, and KVNO; never add `-K`, which prints keys. Keep the keytab in the named volume.

Create a new key while leaving Apache's existing keytab in place:

```bash
docker compose exec kdc sh -c 'rm -f /keytabs/http.next.keytab'
docker compose exec kdc kadmin.local -q 'ktadd -k /keytabs/http.next.keytab HTTP/web.lab.test@LAB.TEST'
docker compose exec client kdestroy
docker compose exec client kinit alice@LAB.TEST
docker compose exec client kvno HTTP/web.lab.test@LAB.TEST
docker compose exec client curl --fail --negotiate -u : https://web.lab.test/private/
```

The new ticket has a higher KVNO and the authenticated request should fail while Apache still has the old key. Destroying the cache first matters: an old service ticket could still work with the old server key. Inspect `docker compose logs --tail=30 web` for the GSSAPI error; the precise HTTP error can vary.

Deploy the new keytab atomically within its volume and restart Apache to discard any cached acceptor credentials:

```bash
docker compose exec kdc sh -eu -c 'chown root:33 /keytabs/http.next.keytab; chmod 640 /keytabs/http.next.keytab; mv /keytabs/http.next.keytab /keytabs/http.keytab'
docker compose restart web
docker compose up --detach --wait --wait-timeout 120
bash scripts/smoke-test.sh
```

## Checkpoint

Show a changed KVNO, the failed request, and restored access. Explain why distributing a keytab is a secret-management operation. The client has no keytab mount and does not need the HTTP service key.

**Extension:** Explain how preserving old keys during a staged production rotation could avoid interrupting clients that still hold old service tickets. This deliberate local failure is a diagnosis exercise, not a production rotation runbook.

**Next:** [09 — Failures and recovery](09-failures-and-recovery.md).
