# Lab 04 — Queue customer orders

**Time:** 60–90 min. **Objective:** Send and receive SQS messages, then acknowledge a message with its receipt handle.

Run everything from `labs/floci` after `docker compose up -d`. Use `./aws-local` to force local, fake credentials. Repeating resource-create commands may report that resources already exist; use existing names or reset the local emulator.

## Hands-on steps

```bash
./aws-local sqs create-queue --queue-name floci-lab-orders
QUEUE_URL="$(./aws-local sqs get-queue-url --queue-name floci-lab-orders --query QueueUrl --output text)"
./aws-local sqs send-message --queue-url "$QUEUE_URL" --message-body '{"orderId":"demo-1","product":"notebook","quantity":2}'
./aws-local sqs receive-message --queue-url "$QUEUE_URL" --max-number-of-messages 1 --wait-time-seconds 1
# Copy the actual ReceiptHandle from the receive output (not the MessageId):
# ./aws-local sqs delete-message --queue-url "$QUEUE_URL" --receipt-handle YOUR_RECEIPT_HANDLE
```

## Evidence / success criteria

Show a received synthetic JSON order and, after acknowledging it, an empty subsequent receive (allow for queue visibility behavior).

## Investigation and extension

1. Why is the receipt handle different from MessageId? 2. What happens if the consumer crashes before DeleteMessage? 3. Send two more orders and compare order IDs.


