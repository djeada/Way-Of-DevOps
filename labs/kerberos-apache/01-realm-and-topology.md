# Lab 01 — Start a realm and trace the topology

**Time:** 30–45 min · **Goal:** Identify the KDC, application server, client, and trust boundaries.

## Concept

A Kerberos realm is an administrative namespace. Its KDC issues tickets for identities called principals. In this project, `LAB.TEST` is the realm and `kdc.lab.test` is its KDC hostname. A realm name and a DNS domain serve different purposes even when their spelling is similar.

## Hands-on

Run all commands from `labs/kerberos-apache`. Complete the [first-run setup](README.md#first-run), then inspect the environment:

```bash
docker compose config
docker compose ps
docker compose exec client getent hosts kdc.lab.test web.lab.test public.lab.test
docker compose exec client cat /etc/krb5.conf
docker compose exec kdc kadmin.local -q listprincs
docker compose exec client curl --fail https://web.lab.test/healthz
```

Find the explicit KDC entry, the realm mapping, and the two Apache DNS aliases. Identify which Dockerfile stage supplies each service. Confirm that the KDC has no published host port and Apache binds only to host loopback on port 8448.

Compare the mounts with `compose.yaml`: the database belongs to the KDC, the HTTP keytab reaches Apache, and the client receives only the TLS volume. Test the client identity and its access to the TLS files:

```bash
docker compose exec client id
docker compose exec client sh -c 'test -r /run/tls/web.crt && echo "certificate readable"'
docker compose exec client sh -c 'test ! -r /run/tls/web.key && echo "private key unreadable"'
```

## Checkpoint

Record healthy services, resolved names, and `ok`. Explain why the client needs KDC connectivity to obtain tickets, why Apache needs a service key, and why the client should not receive that key. The health principal is infrastructure for the KDC probe, separate from student identities.

**Extension:** Stop only the client with `docker compose stop client`; verify the public health page still works with `docker compose exec web curl --cacert /run/tls/web.crt https://web.lab.test/healthz`. Restore with `docker compose start client`.

**Next:** [02 — Manage principals](02-principals.md).
