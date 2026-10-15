# Lab 09 — Infrastructure as Code

**Time:** 60–90 min. **Objective:** Provision S3/SQS/DynamoDB using Terraform provider endpoints pinned to localhost.

Run everything from `labs/floci` after `docker compose up -d`. Use `./aws-local` to force local, fake credentials. Repeating resource-create commands may report that resources already exist; use existing names or reset the local emulator.

## Hands-on steps

```bash
cd terraform
terraform init
terraform fmt -check
terraform validate
terraform plan -out=lab.tfplan
terraform apply lab.tfplan
cd ..
./aws-local s3api list-buckets
./aws-local sqs list-queues
./aws-local dynamodb list-tables
# After recording evidence: cd terraform && terraform destroy && cd ..
```

## Evidence / success criteria

Show the Terraform plan and that the three floci-lab-iac-* resources exist. Only run terraform from the supplied folder, not from real infrastructure directories.

## Investigation and extension

1. How does the state file relate to repeatability? 2. Modify the SQS resource name and inspect the plan. 3. Why does the provider skip cloud credential validation?


