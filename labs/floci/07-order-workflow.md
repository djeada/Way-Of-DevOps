# Lab 07 — Connect SQS to Lambda

**Time:** 60–90 min. **Objective:** Create an SQS event source mapping and observe batch processing.

Run everything from `labs/floci` after `docker compose up -d`. Use `./aws-local` to force local, fake credentials. Repeating resource-create commands may report that resources already exist; use existing names or reset the local emulator.

## Hands-on steps

```bash
# SECURITY: only in a disposable VM (see Lab 06).
docker compose -f compose.yaml -f compose.lambda.yaml up -d --force-recreate
cd examples && zip -j /tmp/floci-order-worker.zip queue_handler.py && cd ..
./aws-local lambda create-function --function-name floci-lab-order-worker --runtime python3.12 --handler queue_handler.handler --role arn:aws:iam::000000000000:role/floci-lab-lambda-role --zip-file fileb:///tmp/floci-order-worker.zip
QUEUE_ARN="$(./aws-local sqs get-queue-attributes --queue-url "$(./aws-local sqs get-queue-url --queue-name floci-lab-orders --query QueueUrl --output text)" --attribute-names QueueArn --query Attributes.QueueArn --output text)"
./aws-local lambda create-event-source-mapping --function-name floci-lab-order-worker --event-source-arn "$QUEUE_ARN" --batch-size 1
QUEUE_URL="$(./aws-local sqs get-queue-url --queue-name floci-lab-orders --query QueueUrl --output text)"
./aws-local sqs send-message --queue-url "$QUEUE_URL" --message-body '{"orderId":"demo-3","product":"pencil","quantity":3}'
./aws-local lambda list-event-source-mappings --function-name floci-lab-order-worker
```

## Evidence / success criteria

Show the mapping status. Use local function invocation/log output to verify records if background polling is supported; do not infer successful event delivery solely from mapping creation.

## Investigation and extension

1. Why is this asynchronous? 2. How would you implement a dead-letter queue? 3. What would you do if a batch partly fails?

**Note:** This exercise may need additional IAM permissions on the execution role and Lambda/SQS integration support from your Floci version. It intentionally treats automation as an integration test, not a guarantee. Run only with Lab 06's Docker socket warning. 

