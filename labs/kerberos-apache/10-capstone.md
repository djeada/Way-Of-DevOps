# Lab 10 — Deliver an authenticated site and recovery runbook

**Time:** 45–60 min · **Goal:** Demonstrate the complete system and leave a repeatable operating procedure.

## Deliverable

Create a short runbook in `.local/runbook.md` with the realm, service names, startup commands, access matrix, validation steps, and recovery procedure. Use principal names and status codes as evidence; omit passwords, ticket blobs, keytabs, and TLS private keys.

## Hands-on

1. Add `apache/site/web/private/release.html` with a small release note. Confirm anonymous access is `401` and both Alice and Bob can retrieve it with Negotiate.
2. Confirm that Bob still receives `403` on `/admin/`, while Alice receives `200`. Restore any policy edits left from Lab 07.
3. Create a new user with `kadmin.local addprinc`, using preauthentication and `-allow_svr` as in Lab 02. Verify private access with a fresh cache, then destroy that cache.
4. Run the smoke test, outage test, wait for recovery, and run the smoke test again:

```bash
bash scripts/smoke-test.sh
bash scripts/outage-test.sh
docker compose up --detach --wait --wait-timeout 120
bash scripts/smoke-test.sh
```

5. Explain a stale-key incident using the KVNO evidence from Lab 08. Identify the difference between restoring the keytab and changing Apache authorization policy.

## Acceptance criteria

| Check | Expected outcome |
|---|---|
| Certificate verification and virtual hosts | Trusted local TLS; distinct public content |
| Anonymous protected request | 401 with Negotiate challenge |
| Alice on private/admin | 200 / 200 |
| Bob on private/admin | 200 / 403 |
| Wrong password or unknown service | Ticket acquisition fails |
| KDC unavailable | Cached HTTP ticket works; fresh login fails |
| Recovery | Smoke test passes again |
| Cleanup | Lab services removed; chosen persistent state documented |

## Reset and handoff

Remove exercise-only files, restore the baseline Apache configuration, and destroy tickets. Record whether the next student should keep or discard your principal changes:

```bash
docker compose exec client kdestroy
docker compose down --volumes --remove-orphans
```

The full reset deletes this project's KDC database, keytabs, and TLS material. Rebuild/start using the [first-run instructions](README.md#first-run) and rerun the smoke test to demonstrate that the checked-in files recreate the baseline. Stop and remove volumes again when the demonstration is finished. Delete `.local` only after saving any non-secret runbook evidence you need.

**Review:** Explain which requests need the KDC, how Apache learns the client's principal, why TLS is still required, and why deleting a user's cache does not revoke tickets copied elsewhere.
