# Hands-on DevOps lab courses

The repository now includes four independently teachable 10-lab courses:

| Course | Lab topics | Setup |
|---|---|---|
| [Floci local AWS emulator](floci/README.md) | S3, DynamoDB, SQS, SNS, Lambda, IAM, Terraform and an order-processing capstone | Docker Compose + AWS CLI; Terraform and **disposable VM** for advanced Lambda labs |
| [Wireshark + Node.js](wireshark-nodejs/README.md) | TCP, HTTP, JSON, HTTP status, UDP, framing, DNS, TLS and troubleshooting | Docker image + Wireshark (viewer only), no cloud account |
| [Web servers: Nginx + Apache](servers/README.md) | HTTP, containers, ports, static hosting, reverse proxies, TLS, headers, logs and recovery | Docker Compose + curl; OpenSSL for the TLS lab |
| [Kerberos + Apache](kerberos-apache/README.md) | Realms, principals, tickets, Apache virtual hosts, HTTPS, Negotiate SSO, authorization, key rotation and recovery | Docker Compose + Bash; includes its own Kerberos and curl client |

## Safety and recordings

For web server exercises, bind host ports to 127.0.0.1, use only the disposable localhost certificate, and never put production data or credentials into the lab. See [server lab safety notes](servers/README.md#safety-and-scope).

The Kerberos + Apache course uses an internal Compose network, public disposable teaching passwords, and a self-signed lab certificate. Keep keytabs, caches, and private keys out of Git and recordings. Its outage and key-rotation exercises deliberately interrupt this local lab; follow the [course reset instructions](kerberos-apache/README.md#scope-and-reset).

For Wireshark, use [Docker-isolated capture](wireshark-nodejs/ISOLATED_DOCKER.md) with `--network none`. Never record real Ethernet/Wi-Fi traffic for redistribution. Open the generated PCAP in the host Wireshark viewer; verify IPv4 endpoints remain `127.0.0.1` before sharing. Screen recordings themselves can still reveal identities, notifications or paths.

For Floci, the `aws-local` wrapper forces requests to local `127.0.0.1:4566` with fake credentials. The optional Lambda exercises use a Docker socket and should run **only in a dedicated, disposable VM**. No production services or real credentials should be involved.

## Verification

Web server examples include a [local smoke test](servers/scripts/smoke-test.sh) requiring running Compose services. Wireshark Node examples have functional smoke tests: `cd labs/wireshark-nodejs && npm test`. A Docker-capable computer is still required to verify packet-capture behavior. Floci operations and Lambda integration likewise require a live emulator; follow the per-lab evidence checks.

Kerberos + Apache includes [authentication and authorization checks](kerberos-apache/scripts/smoke-test.sh) and a [KDC outage check](kerberos-apache/scripts/outage-test.sh), both requiring running Compose services. The [integration workflow](../.github/workflows/kerberos-apache-labs.yml) starts the lab, runs these checks, verifies recovery, and removes its volumes.
