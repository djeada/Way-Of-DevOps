# Lab 10 — Launch the local store backend

**Time:** 60–90 min. **Objective:** Put together catalogue, storage and event messaging; verify one complete synthetic transaction.

Run everything from `labs/floci` after `docker compose up -d`. Use `./aws-local` to force local, fake credentials. Repeating resource-create commands may report that resources already exist; use existing names or reset the local emulator.

## Hands-on steps

```bash
# Assumes you have completed Labs 02–05.
./aws-local s3 ls s3://floci-lab-images/
./aws-local dynamodb get-item --table-name floci-lab-products --key '{"id":{"S":"notebook"}}'
QUEUE_URL="$(./aws-local sqs get-queue-url --queue-name floci-lab-orders --query QueueUrl --output text)"
./aws-local sqs send-message --queue-url "$QUEUE_URL" --message-body '{"orderId":"capstone-1","product":"notebook","quantity":1}'
./aws-local sqs receive-message --queue-url "$QUEUE_URL" --max-number-of-messages 1
./aws-local sns publish --topic-arn "$(./aws-local sns create-topic --name floci-lab-order-events --query TopicArn --output text)" --message '{"event":"order.placed","orderId":"capstone-1"}'
```

## Evidence / success criteria

Deliver an architecture diagram, the S3 object key, the DynamoDB product, an SQS order payload and a SNS notification. Include a flow narrative and test failures without real data.

## Investigation and extension

1. Add validation via Lab 06 (optional dedicated VM). 2. Describe idempotency and retries. 3. Identify which tests would need to run against real AWS before deployment.

**Capstone scope:** S3, DynamoDB, SQS and SNS are wired together by the *student's manual commands*. A real API or production end-to-end order processor is an optional extension, not claimed as complete by these commands.

