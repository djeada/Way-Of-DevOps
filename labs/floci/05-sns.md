# Lab 05 — Fan out order notifications

**Time:** 60–90 min. **Objective:** Create SNS topic and SQS subscription; observe event envelopes.

Run everything from `labs/floci` after `docker compose up -d`. Use `./aws-local` to force local, fake credentials. Repeating resource-create commands may report that resources already exist; use existing names or reset the local emulator.

## Hands-on steps

```bash
TOPIC_ARN="$(./aws-local sns create-topic --name floci-lab-order-events --query TopicArn --output text)"
QUEUE_URL="$(./aws-local sqs get-queue-url --queue-name floci-lab-orders --query QueueUrl --output text)"
QUEUE_ARN="$(./aws-local sqs get-queue-attributes --queue-url "$QUEUE_URL" --attribute-names QueueArn --query Attributes.QueueArn --output text)"
./aws-local sns subscribe --topic-arn "$TOPIC_ARN" --protocol sqs --notification-endpoint "$QUEUE_ARN"
./aws-local sns publish --topic-arn "$TOPIC_ARN" --message '{"event":"order.placed","orderId":"demo-2"}'
./aws-local sqs receive-message --queue-url "$QUEUE_URL"
```

## Evidence / success criteria

Record the topic ARN, subscription and message body. In more strictly configured environments, an SQS resource policy permitting SNS SendMessage may be required.

## Investigation and extension

1. Explain topic vs queue. 2. How does fanout differ from a single work queue? 3. Why can repeated subscriptions create duplicate notifications?


