# GitOps

GitOps manages a system by declaring its desired state in version control and having software agents reconcile the running system with that declaration. Git provides review and history; the reconciliation loop keeps the system aligned with the accepted configuration.

## Core principles

The OpenGitOps principles are: describe the desired state declaratively, preserve its versions and history, let agents pull it automatically, and continuously reconcile the actual state with it.

Storing a deployment script in Git gives the script a history. A pipeline that runs that script once does not, by itself, provide continuous reconciliation.

## A typical workflow

1. CI tests application code and publishes an immutable artifact.
2. A proposed configuration change references that artifact's version or digest.
3. Reviewers inspect the deployment change and merge it.
4. A controller such as Argo CD or Flux pulls the desired state and applies it.
5. The controller reports differences and health; operators verify the rollout.

Application and environment configuration can live in one repository or several. Choose boundaries that make ownership and access clear. Keep secrets in an appropriate secret store or use a reviewed encryption workflow; plaintext secrets should not be committed.

## Drift, rollback, and limits

Drift is a difference between the declared configuration and the running system. A controller can report or correct it according to its policy. Document how emergency changes are made and then captured in the source of truth so reconciliation does not undo them unexpectedly.

Reverting a configuration commit can restore an earlier artifact or setting. It does not undo database writes, restore deleted data, or prove that the earlier application still supports the current schema. Verify health after reconciliation and use the [recovery plan](backup_and_recovery.md) for data loss.

Start with a small service and restricted controller permissions. GitOps is useful when declarative management, review, and drift control reduce operational work; it also adds a controller and access model that the team must maintain.

Reference: [OpenGitOps principles](https://opengitops.dev/).
