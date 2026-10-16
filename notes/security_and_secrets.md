# Security and secrets

Security in operations begins with clear boundaries: who can change a system, which workloads can reach it, what data they can access, and how those decisions are recorded and reviewed.

## Identity and access

Use named identities for people, multifactor authentication, and separate workload identities for services. Grant the least access needed for the task and review it when responsibilities change. Keep an audited emergency-access procedure available.

Prefer short-lived workload credentials and federation where supported. Separate development and production access. Restrict cloud role trust as well as the permissions attached to the role: the trust policy decides who may assume it.

Authentication establishes an identity. Authorization determines what that identity may do. Network reachability alone is not proof that a request should be accepted.

## Secrets throughout their lifecycle

Store passwords, tokens, signing keys, and similar credentials in an appropriate secret store. Deliver them to the workload with limited access, avoid embedding them in source or images, and prevent them from appearing in logs or command output.

Document who owns each secret, how it is issued, how applications reload it, and how to revoke or replace it. Test rotation with the dependent services so a credential change does not cause an outage.

If a secret is exposed, revoke or replace it and investigate its use. Removing it from the current file does not invalidate copies in Git history, logs, artifacts, or caches. Plan any history cleanup separately after the credential has been addressed.

## Reduce exposure

Expose only the intended application entry points. Restrict administrator access and database listeners, validate TLS certificates, patch supported software, and remove unused services and privileges.

Use application-level authorization for sensitive actions and data. Protect against excessive requests and unbounded work with limits and timeouts. Encrypt stored data where appropriate and ensure the keys remain available for recovery.

## Protect the delivery path

Review dependencies and container bases, retain lockfiles, and investigate relevant vulnerability reports. Pin reusable CI actions to reviewed commits. Restrict who can publish release artifacts and change deployment configuration, and retain source and artifact identifiers for traceability.

Keep untrusted build jobs away from deployment credentials and privileged runners. A job running someone else's code can execute that code's installation and test scripts too. Use [GitHub Actions trust boundaries](github_actions.md) when designing repository automation.

## Verify the boundaries

Test that a restricted identity is denied an operation outside its role, that an expired credential stops working, and that important administrative actions are logged. Keep logs protected and retain only the information needed for operations and investigation.

References: [AWS temporary credentials](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp.html) and [GitHub Actions secure use](https://docs.github.com/en/actions/reference/security/secure-use). Related: [database operations](best_practices.md) and [backup and recovery](backup_and_recovery.md).
