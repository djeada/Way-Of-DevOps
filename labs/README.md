# Hands-on DevOps lab courses

The repository now includes two independently teachable 10-lab courses:

| Course | Lab topics | Setup |
|---|---|---|
| [Floci local AWS emulator](floci/README.md) | S3, DynamoDB, SQS, SNS, Lambda, IAM, Terraform and an order-processing capstone | Docker Compose + AWS CLI; Terraform and **disposable VM** for advanced Lambda labs |
| [Wireshark + Node.js](wireshark-nodejs/README.md) | TCP, HTTP, JSON, HTTP status, UDP, framing, DNS, TLS and troubleshooting | Docker image + Wireshark (viewer only), no cloud account |

## Safety and recordings

For Wireshark, use [Docker-isolated capture](wireshark-nodejs/ISOLATED_DOCKER.md) with `--network none`. Never record real Ethernet/Wi-Fi traffic for redistribution. Open the generated PCAP in the host Wireshark viewer; verify IPv4 endpoints remain `127.0.0.1` before sharing. Screen recordings themselves can still reveal identities, notifications or paths.

For Floci, the `aws-local` wrapper forces requests to local `127.0.0.1:4566` with fake credentials. The optional Lambda exercises use a Docker socket and should run **only in a dedicated, disposable VM**. No production services or real credentials should be involved.

## Verification

Wireshark Node examples have functional smoke tests: `cd labs/wireshark-nodejs && npm test`. A Docker-capable computer is still required to verify packet-capture behavior. Floci operations and Lambda integration likewise require a live emulator; follow the per-lab evidence checks.
