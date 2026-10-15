# Lab 03 — Build a Products table

**Time:** 60–90 min. **Objective:** Model key-value access with DynamoDB and compare GetItem with Scan.

Run everything from `labs/floci` after `docker compose up -d`. Use `./aws-local` to force local, fake credentials. Repeating resource-create commands may report that resources already exist; use existing names or reset the local emulator.

## Hands-on steps

```bash
./aws-local dynamodb create-table --table-name floci-lab-products --attribute-definitions AttributeName=id,AttributeType=S --key-schema AttributeName=id,KeyType=HASH --billing-mode PAY_PER_REQUEST
./aws-local dynamodb put-item --table-name floci-lab-products --item '{"id":{"S":"notebook"},"price":{"N":"4.50"},"stock":{"N":"12"}}'
./aws-local dynamodb put-item --table-name floci-lab-products --item '{"id":{"S":"pencil"},"price":{"N":"0.80"},"stock":{"N":"100"}}'
./aws-local dynamodb get-item --table-name floci-lab-products --key '{"id":{"S":"notebook"}}'
./aws-local dynamodb scan --table-name floci-lab-products
```

## Evidence / success criteria

Show that GetItem returns a selected product and Scan lists the table's sample products.

## Investigation and extension

1. What is the partition key? 2. Update notebook stock to 10 using PutItem and observe replacement semantics. 3. Why would a table-wide Scan be unsuitable for a large product catalogue?


