# Kerberos + Apache: 10 hands-on labs

Build a local MIT Kerberos realm, operate Apache HTTP Server, and use Kerberos tickets to authenticate HTTPS requests. The course connects identity administration with web server configuration, access control, and recovery.

**Level:** Intermediate. **Time:** 30–60 minutes per lab. Follow the labs in order; they share one environment. For an introduction to document roots and reverse proxies, start with the [web server course](../servers/README.md).

## Environment

| Service | Role | Address inside Compose |
|---|---|---|
| `kdc` | Ticket issuing and local principal administration | `kdc.lab.test:88`, realm `LAB.TEST` |
| `web` | Apache 2.4, TLS, and `mod_auth_gssapi` | `https://web.lab.test` and `https://public.lab.test` |
| `client` | Non-root student account, MIT tools, and curl with SPNEGO | Commands run with `docker compose exec client ...` |

The services share an internal Docker network. Only Apache is published to the host, at **127.0.0.1:8448**. Docker DNS resolves the `.test` names within this project; no host DNS or hosts-file changes are needed. Administrative commands use `kadmin.local` inside the KDC container; there is no remote administration daemon.

The KDC database, HTTP keytab, and disposable TLS certificate use named volumes. Apache receives the HTTP keytab read-only; the client receives no keytab. A separate KDC-only health principal checks ticket issuance. The client can read the public TLS certificate, but its non-root user cannot read the TLS private key.

## First run

Prerequisites: Docker Engine/Desktop with Compose v2 supporting `up --wait`, a Bash-compatible shell, and a text editor. Images build from Debian Bookworm packages; internet access is needed to build them. No Active Directory, cloud account, host Kerberos configuration, or host curl SPNEGO support is required.

From the repository root:

```bash
cd labs/kerberos-apache
docker compose up --build --detach --wait --wait-timeout 180
docker compose ps
docker compose exec client curl --fail https://web.lab.test/healthz
bash scripts/smoke-test.sh
```

Expected: all three services run, the health response is `ok`, and the test prints `PASS`. The test checks both allowed and denied access and destroys its client tickets when it finishes.

| Principal | Disposable password | Web access |
|---|---|---|
| `alice@LAB.TEST` | `Alice-lab-only!` | `/private/` and `/admin/` |
| `bob@LAB.TEST` | `Bob-lab-only!` | `/private/`; `/admin/` returns 403 |
| `HTTP/web.lab.test@LAB.TEST` | Random service key in a keytab | Used by Apache to accept tickets |

These are public teaching credentials. Enter the relevant password when `kinit` prompts:

```bash
docker compose exec client kinit alice@LAB.TEST
docker compose exec client klist
docker compose exec client curl --fail --negotiate -u : https://web.lab.test/private/
docker compose exec client kdestroy
```

The container's curl trusts `/run/tls/web.crt` via `CURL_CA_BUNDLE`. Use the hostname in the URL: it participates in certificate validation and service-principal selection. A browser on your workstation does not inherit the container's credential cache.

## Lab sequence

| Lab | Focus | Evidence |
|---|---|---|
| [01 — Start a realm](01-realm-and-topology.md) | KDC, realm, DNS, processes | Healthy services and resolved names |
| [02 — Manage principals](02-principals.md) | User/service identities, preauthentication | New user can obtain a ticket |
| [03 — Manage tickets](03-ticket-lifecycle.md) | TGT, service ticket, renewal, expiry | Cache changes before/after requests |
| [04 — Operate Apache virtual hosts](04-apache-virtual-hosts.md) | Modules, document roots, SNI, 404s | Different content on the same listener |
| [05 — TLS and safe configuration](05-tls-and-config.md) | Trust, syntax checks, graceful reloads | Rejected invalid edit; restored service |
| [06 — Negotiate single sign-on](06-negotiate-sso.md) | HTTP challenge, SPNEGO, service identity | Anonymous 401 becomes authenticated 200 |
| [07 — Authorize users](07-authorization.md) | Full principals, authentication vs authorization | Alice 200 and Bob 403 on `/admin/` |
| [08 — Rotate service keys](08-keytabs-and-rotation.md) | Keytabs, permissions, KVNO, deployment | Repaired stale-key failure |
| [09 — Diagnose outages](09-failures-and-recovery.md) | Cached tickets, KDC dependency, logs | Existing access survives; new login fails |
| [10 — Capstone and cleanup](10-capstone.md) | Reproducibility, runbook, access matrix | Passing checks and a clean reset |

## Files and operations

- `kerberos/` is copied into images. After editing it or a startup script, rebuild with `docker compose up --build --detach --wait`.
- `apache/config/` and `apache/site/` are mounted read-only into Apache. Content edits appear immediately; configuration edits require `docker compose exec web apache2ctl -t` followed by `docker compose exec web apache2ctl -k graceful`.
- `scripts/smoke-test.sh` checks TLS, virtual hosts, wrong passwords, service tickets, anonymous denial, Alice/Bob authorization, and cache cleanup.
- `scripts/outage-test.sh` deliberately stops the KDC, checks cached access and failed fresh login, then restarts it with an exit trap. Run it on this disposable project only, then wait for health and repeat the smoke test.
- The [GitHub Actions workflow](../../.github/workflows/kerberos-apache-labs.yml) runs these integration checks on a Docker-capable runner for changes to this course.

```bash
docker compose logs --tail=30 kdc web
docker compose exec web apache2ctl -S
bash scripts/outage-test.sh
docker compose up --detach --wait --wait-timeout 120
bash scripts/smoke-test.sh
```

Optional host-side public-page check, using host curl and an explicit trust file:

```bash
mkdir -p .local
docker compose cp web:/run/tls/web.crt .local/web.crt
curl --noproxy '*' --cacert .local/web.crt \
  --resolve web.lab.test:8448:127.0.0.1 https://web.lab.test:8448/
```

## Scope and reset

Use disposable identities only. Keytabs and caches contain credentials; do not commit or share them. Avoid recording HTTP Authorization headers or using `klist -K`, which prints keys. The Compose services share the host clock; do not alter the host clock to simulate skew. TLS and Kerberos solve different problems: tickets authenticate identities; HTTPS also protects request and response contents.

The self-signed certificate lasts seven days. A full volume reset generates a new one and also removes **all lab principals and keytabs**. Ordinary `down` preserves them:

```bash
docker compose down
# Full reset of this project's lab state, when ready to discard it:
docker compose down --volumes --remove-orphans
rm -rf .local
```

Restart with the first-run command. Revert any configuration/content exercises separately before repeating the baseline tests. This is a single-KDC teaching environment; production availability, managed trust, account lifecycle, and controlled secret distribution require additional design.

## References

- [MIT Kerberos administration](https://web.mit.edu/kerberos/krb5-latest/doc/admin/index.html) and [user commands](https://web.mit.edu/kerberos/krb5-latest/doc/user/user_commands/index.html).
- [Apache virtual hosts](https://httpd.apache.org/docs/2.4/vhosts/name-based.html), [authentication and authorization](https://httpd.apache.org/docs/2.4/howto/auth.html), and [TLS](https://httpd.apache.org/docs/2.4/ssl/).
- [`mod_auth_gssapi` directives](https://github.com/gssapi/mod_auth_gssapi#configuration-directives).
- [curl authentication options](https://curl.se/docs/manpage.html#--negotiate).
