# Lab 08 — Design least-privilege policies

**Time:** 60–90 min. **Objective:** Create and inspect IAM roles and narrowly scoped policies in the emulator.

Run everything from `labs/floci` after `docker compose up -d`. Use `./aws-local` to force local, fake credentials. Repeating resource-create commands may report that resources already exist; use existing names or reset the local emulator.

## Hands-on steps

```bash
./aws-local iam create-policy --policy-name floci-lab-read-products --policy-document file://examples/read-products-policy.json
./aws-local iam get-policy --policy-arn arn:aws:iam::000000000000:policy/floci-lab-read-products
./aws-local iam get-policy-version --policy-arn arn:aws:iam::000000000000:policy/floci-lab-read-products --version-id v1
```

## Evidence / success criteria

Explain each action and the specific DynamoDB table ARN. A created policy is not evidence that every emulated service enforces all authorization rules.

## Investigation and extension

1. Why is dynamodb:* too permissive? 2. Add a separate write policy (as an exercise, don't reuse the read-only one). 3. Describe an AWS production security test versus a local API-emulator test.


