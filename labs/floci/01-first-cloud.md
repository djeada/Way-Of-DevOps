# Lab 01 — Build your first local cloud

**Time:** 60–90 min. **Objective:** Confirm the emulator endpoint and explain why dummy credentials are safe here.

Run everything from `labs/floci` after `docker compose up -d`. Use `./aws-local` to force local, fake credentials. Repeating resource-create commands may report that resources already exist; use existing names or reset the local emulator.

## Hands-on steps

```bash
docker compose ps
./aws-local s3 ls
./aws-local sqs list-queues
./aws-local dynamodb list-tables
./aws-local sts get-caller-identity
```

## Evidence / success criteria

Show the running Compose service and successful JSON responses. Document the endpoint, region and dummy account ID. Explain why no real cloud account is required.

## Investigation and extension

1. Which endpoint did the AWS CLI contact? 2. Which AWS credentials would be unsafe to use? 3. Stop Floci and record the connection error, then restart it.


