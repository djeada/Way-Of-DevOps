# Lab 07 — Separate authentication from authorization

**Time:** 40–60 min · **Goal:** Prove that a valid Kerberos identity can still be denied a resource.

## Concept

`/private/` accepts any authenticated lab principal. `/admin/` allows only `alice@LAB.TEST`. Keeping full principal names avoids silently collapsing identities from different realms. `AuthzSendForbiddenOnFailure On` makes an authenticated authorization failure return `403` on the admin path.

## Hands-on

```bash
docker compose exec client kinit alice@LAB.TEST
docker compose exec client curl --negotiate -u : -s -o /dev/null -w '%{http_code}\n' https://web.lab.test/private/
docker compose exec client curl --negotiate -u : -s -o /dev/null -w '%{http_code}\n' https://web.lab.test/admin/
docker compose exec client kdestroy
docker compose exec client kinit bob@LAB.TEST
docker compose exec client curl --negotiate -u : -s -o /dev/null -w '%{http_code}\n' https://web.lab.test/private/
docker compose exec client curl --negotiate -u : -s -o /dev/null -w '%{http_code}\n' https://web.lab.test/admin/
```

Expected matrix:

| Identity | `/private/` | `/admin/` |
|---|---|---|
| Anonymous | 401 | 401 |
| Alice | 200 | 200 |
| Bob | 200 | 403 |

Back up `apache/config/site.conf` to `.local/authorization.backup`. Change only the admin rule to `Require user alice@LAB.TEST bob@LAB.TEST`, test syntax, then reload:

```bash
docker compose exec web apache2ctl -t && docker compose exec web apache2ctl -k graceful
```

Repeat Bob's admin request; expect `200`. Restore the backup, validate, reload, and verify that Bob returns to `403`. Destroy Bob's cache and run `bash scripts/smoke-test.sh` to prove the original access matrix has been restored.

## Checkpoint

Use the access log's principal and status fields to explain the difference between unknown identity and denied permission. Explain why passing a syntax check cannot detect an accidentally broadened `Require` rule.

**Extension:** If you created Carol in Lab 02, verify that Carol gets private access and is denied admin access without changing the baseline rule.

**Next:** [08 — Keytabs and rotation](08-keytabs-and-rotation.md).
