# Lab 06 — Authenticate HTTPS with Negotiate

**Time:** 40–60 min · **Goal:** Follow an anonymous challenge through to a successful Kerberos-authenticated request.

## Concept

Apache advertises HTTP Negotiate for protected paths. A capable client presents a Kerberos service ticket through SPNEGO. The configured module accepts only the Kerberos mechanism, disables Basic fallback, and requires TLS. Apache's keytab identifies `HTTP/web.lab.test@LAB.TEST`.

## Hands-on

Inspect the anonymous response; it contains no authenticated client token:

```bash
docker compose exec client curl -i https://web.lab.test/private/
docker compose exec client curl --version
```

Expect `401` and `WWW-Authenticate: Negotiate`. Confirm SPNEGO is listed by the client build. Obtain Alice's TGT, inspect the cache, and authenticate:

```bash
docker compose exec client kinit alice@LAB.TEST
docker compose exec client klist
docker compose exec client curl --fail --negotiate -u : https://web.lab.test/private/
docker compose exec client klist
docker compose logs --tail=20 web
```

Expect the private page and an HTTP service ticket in the cache. `-u :` activates curl's authentication option without putting Alice's password into the URL or sending it as a Basic credential. The password was used by `kinit`; curl consumes the credential cache.

Repeat the authenticated request and compare the cache. Then destroy tickets and repeat the *anonymous* request:

```bash
docker compose exec client kdestroy
docker compose exec client curl -s -o /dev/null -w '%{http_code}\n' https://web.lab.test/private/
```

Expect `401`. This lab disables module sessions so requests demonstrate ticket-based authentication directly.

## Checkpoint

Explain the roles of TGT, HTTP service ticket, keytab, and HTTPS. Record status codes and the authenticated principal from the access log. Do not record verbose authenticated HTTP headers: Authorization and Negotiate response fields can contain authentication tokens.

**Extension:** Compare an authenticated request with one made without `--negotiate`, while a valid TGT exists. A cache alone does not make every HTTP client authenticate automatically.

**Next:** [07 — Authorization](07-authorization.md).
