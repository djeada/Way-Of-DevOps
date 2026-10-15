"""Lab 07: handler for SQS event records. Educational example."""
import json

def handler(event, context):
    processed = []
    failures = []
    for record in event.get("Records", []):
        try:
            order = json.loads(record["body"])
            if not order.get("product") or int(order.get("quantity", 0)) < 1:
                raise ValueError("Invalid order")
            processed.append(order["product"])
        except (ValueError, TypeError, KeyError, json.JSONDecodeError):
            failures.append({"itemIdentifier": record.get("messageId", "")})
    print("Demo orders processed:", processed)
    # For event-source mapping, partial failures require ReportBatchItemFailures.
    return {"batchItemFailures": failures}
