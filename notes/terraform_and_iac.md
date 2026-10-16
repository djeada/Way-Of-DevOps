# Terraform and infrastructure as code

Infrastructure as code (IaC) describes infrastructure in files that can be reviewed, versioned, and applied repeatably. Terraform uses provider APIs to manage resources and records their relationship to configuration in state.

## The working cycle

1. Write resource configuration and declare provider and module versions.
2. Run `terraform init` to initialize the backend and install dependencies.
3. Run `terraform fmt -check` and `terraform validate` for formatting and configuration checks.
4. Run `terraform plan -out=tfplan` and inspect the proposed changes.
5. After review, run `terraform apply tfplan` to apply that saved plan.
6. Check the resulting service and run another plan when needed to investigate unexpected differences.

These commands operate in the current working directory and selected backend/workspace. Confirm the target account and environment before planning or applying. Applying a saved plan executes it without another interactive approval prompt, so review belongs before that step.

A successful validation checks configuration consistency, not service availability, access rights, cost, or every provider constraint. Treat create, update, replacement, and deletion actions differently during review.

## State is operational data

State maps resource addresses to real objects. Use a remote backend with access controls, encryption, versioning or backups, and locking where supported. Coordinate writers; do not disable locking to bypass another operation.

State and saved plans can contain credentials or other sensitive values. Marking an output `sensitive` hides it from normal display; it does not by itself remove the value from state. Keep state, saved plans, and local secret variable files out of Git. Commit configuration and the provider dependency lockfile, `.terraform.lock.hcl`.

Use supported import and move mechanisms when adopting existing resources or refactoring addresses. Removing an object from state stops Terraform managing it; it does not delete the remote object. Editing state JSON directly is an exceptional repair task and requires a backup and a clear recovery plan.

## Modules and environments

Group related resources into modules with clear inputs, outputs, and ownership. Read a module's implementation and lifecycle behavior before adopting it. Version shared modules and keep abstractions small enough to understand their plans.

Give environments separate state and appropriate credential boundaries. CLI workspaces separate state instances but do not create an access-control boundary by themselves. Avoid one large state file that forces unrelated teams or services to change together.

## Limits and drift

Terraform can use many providers, but cloud resources remain provider-specific. An AWS network definition cannot be applied unchanged to Google Cloud just because both use Terraform syntax.

Terraform manages the resource properties supported by its providers. It does not generally enforce every file and package inside a VM. Use images, bootstrap configuration, or configuration management for that work. Compare these responsibilities in [choosing infrastructure tools](intro_to_tools.md).

Drift is a change outside the declared configuration. Review it before accepting or correcting it. An emergency console change must be reconciled into the intended source of truth; blindly applying an old configuration can undo a necessary repair.

References: [state](https://developer.hashicorp.com/terraform/language/state), [state locking](https://developer.hashicorp.com/terraform/language/state/locking), and [sensitive data](https://developer.hashicorp.com/terraform/language/manage-sensitive-data). Practice with the [local Terraform lab](../labs/floci/09-terraform.md).
