# Lesson 07 — HTTPS, certificates and trust

**Time:** 45–60 min · **Goal:** Observe a TLS connection and distinguish encryption from certificate trust.

## Concept

TLS negotiates an encrypted channel. HTTPS is HTTP over TLS. A self-signed certificate can demonstrate the handshake, but it does **not** establish public identity. In production use a certificate issued and renewed by a trusted CA, verify the server's name and certificate chain, and configure HTTPS on your real ingress.

The optional `nginx-tls` Compose service listens on **127.0.0.1:8443**, not the public internet. It shares the gateway routes but keeps local HTTP on 8080 for comparison.

## Hands-on

Install OpenSSL if needed; create a short-lived local key and certificate (both remain under the Git-ignored `certs/` folder):

```bash
./scripts/make-local-cert.sh
docker compose -f compose.yaml -f compose.tls.yaml up -d --build
docker compose -f compose.yaml -f compose.tls.yaml ps
curl -I http://127.0.0.1:8080/
curl --cacert certs/localhost.pem -I https://localhost:8443/
curl --cacert certs/localhost.pem https://localhost:8443/apache/
```

If you omit `--cacert`, the local self-signed certificate normally fails verification. **Do not normalize `curl -k` as a fix** for production certificate failures. Examine the certificate:

```bash
openssl x509 -in certs/localhost.pem -noout -subject -dates -ext subjectAltName
```

It is issued for `localhost` (and 127.0.0.1). The explicit `--cacert` option makes curl trust this lab's file for this one command; browsers will still display a warning unless you explicitly trust it.

## Checkpoint

Show a successful, verified local `curl --cacert` request, the certificate's dates and SAN, and the difference between `http://` and `https://`. Explain why the same certificate must never be reused for a real domain.

**Cleanup (if not continuing):** `docker compose -f compose.yaml -f compose.tls.yaml down` and `rm -rf certs`. Otherwise keep HTTPS running for the capstone.

**Next:** [08 — Logs and health checks](08-logs-and-health.md).
