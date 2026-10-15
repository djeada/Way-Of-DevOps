# Lab 06 — Validate orders with Lambda

**Time:** 60–90 min. **Objective:** Package a Python handler, create an IAM role, and invoke through the local Lambda API.

Run everything from `labs/floci` after `docker compose up -d`. Use `./aws-local` to force local, fake credentials. Repeating resource-create commands may report that resources already exist; use existing names or reset the local emulator.

## Hands-on steps

```bash
# SECURITY: do these steps ONLY inside a disposable VM. See warning below.
docker compose -f compose.yaml -f compose.lambda.yaml up -d --force-recreate
./aws-local iam create-role --role-name floci-lab-lambda-role --assume-role-policy-document file://examples/trust-policy.json
cd examples && zip -j /tmp/floci-validate-order.zip index.py && cd ..
./aws-local lambda create-function --function-name floci-lab-validate-order --runtime python3.12 --handler index.handler --role arn:aws:iam::000000000000:role/floci-lab-lambda-role --zip-file fileb:///tmp/floci-validate-order.zip
./aws-local lambda invoke --function-name floci-lab-validate-order --cli-binary-format raw-in-base64-out --payload '{"product":"notebook","quantity":2}' response.json
cat response.json
```

## Evidence / success criteria

Expect accepted=true for a valid order, then invoke with quantity 0 and explain rejection.

## Investigation and extension

1. What runs inside a Lambda container? 2. Why package a handler? 3. What changes in the IAM execution role in production?

**Warning:** The Docker socket in `compose.lambda.yaml` grants broad control of the host Docker daemon. Run only on a disposable isolated VM, not an everyday machine. Remove the overlay after use: `docker compose down && docker compose up -d`. Docker-backed Lambda support and chosen runtime should be confirmed against the installed Floci version; local tests are not equivalent to AWS. 

