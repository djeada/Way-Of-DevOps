# Floci: 10 AWS-emulation labs

**Audience:** beginner/intermediate DevOps students. **Duration:** 60–90 minutes each.

Floci is a free local **AWS** API emulator. This course walks through one small e-commerce backend using S3, DynamoDB, SQS, SNS, Lambda, IAM and Terraform. Every AWS CLI command is wrapped by `./aws-local`, which pins the API endpoint to `127.0.0.1:4566` and overrides real credentials with disposable test values. **Never run the commands directly against AWS.**

## Setup

Prerequisites: Docker + Compose, AWS CLI v2, Bash, Python 3 (for the optional handler), `zip` (Lab 6), Terraform/OpenTofu (Lab 9). No AWS account is required.

```bash
cd labs/floci
docker compose up -d
chmod +x aws-local
./aws-local s3 ls
```

The emulator is published only on the host's loopback interface. Its Docker network is internal-only. **Do not use your actual cloud credentials, real datasets, company DNS, or public endpoints.** Docker image pulls and Terraform provider installation may require internet initially; lab API calls target Floci. This is not a security boundary against a malicious emulator image or privileged Docker administrator.

## Labs

| # | Exercise | Concept |
|---|---|---|
| 01 | [Start local cloud](01-first-cloud.md) | Floci, local endpoints |
| 02 | [Store product images](02-s3.md) | S3 object storage |
| 03 | [Products database](03-dynamodb.md) | DynamoDB |
| 04 | [Customer orders](04-sqs.md) | SQS queues |
| 05 | [Publish order events](05-sns.md) | SNS → SQS fanout |
| 06 | [Validate orders](06-lambda.md) | Lambda and Docker-backed execution |
| 07 | [Event-driven processing](07-order-workflow.md) | Lambda + SQS event source |
| 08 | [Least privilege](08-iam.md) | IAM policy modelling |
| 09 | [Declare infrastructure](09-terraform.md) | Terraform |
| 10 | [Storefront capstone](10-capstone.md) | End-to-end integration |

The labs use resource names prefixed with `floci-lab-`; share an emulator across sessions but do not run parallel student teams against the same state. For classroom concurrency, run separate VMs/Compose projects and choose different published localhost ports plus `aws-local` configuration.

**Teaching note:** Floci emulates AWS APIs; a successful emulator run does not prove production parity, particularly IAM authorization, timing, eventual consistency, or container-backed execution. Lab 6–7 require the **optional** `compose.lambda.yaml` overlay (Docker socket access): run those **only in a disposable trusted VM**; see the lab warning. The remaining labs run without the Docker socket.

## Course grading

Capture command outputs (synthetic IDs only), explain protocol/service behavior, extend an exercise, and submit a short architecture diagram. Suggested rubric: functionality 40%, explanation 30%, verification 20%, cleanup 10%.

## References

- https://floci.io/floci/getting-started/quick-start/
- https://github.com/floci-io/floci/blob/main/docs/services/index.md
- https://floci.io/floci/getting-started/terraform/

## Shutdown

```bash
docker compose down
```
