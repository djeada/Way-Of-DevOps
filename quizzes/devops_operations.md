# DevOps Operations Quiz

Notes: [Observability and incidents](../notes/observability.md), [Security and secrets](../notes/security_and_secrets.md), [Database operations](../notes/best_practices.md), [Backup and recovery](../notes/backup_and_recovery.md), [Managing servers in a small company](../notes/server_in_small_company.md), [Moving from manual operations to repeatable systems](../notes/modern_vs_old.md), [MLOps fundamentals](../notes/mlops.md)

Check your understanding of telemetry, SLOs, incident response, access and secrets, database changes, recovery, gradual automation and ML systems in production.

#### Q. A checkout request is slow, and it passes through a gateway, an order service, a payment service and a database. Which signal best shows where the time was spent?

* [ ] A metric of total requests per minute
* [x] A distributed trace of that request
* [ ] A log line from the gateway's startup
* [ ] A dashboard of average CPU per host

> **Explanation:** Traces connect operations across a request's path through several components, showing the duration of each span. Metrics summarize measurements over time, and logs describe individual events with context.

#### Q. Average latency for an API is 120 ms, yet users complain that some requests take several seconds. Which measurement reveals the problem?

* [ ] The mean latency over a longer window
* [ ] The total number of requests per day
* [x] A high percentile such as p99 latency
* [ ] The minimum latency seen per instance

> **Explanation:** Percentiles reveal slow tails that an average can hide. Also separate successful and failed request latency, since fast errors can make an average look healthy.

#### Q. A developer adds a `user_id` label to a request-count metric, and the metrics backend's memory use explodes. Why?

* [x] Each distinct user ID creates a new time series
* [ ] Labels are stored as logs instead of metrics
* [ ] Prometheus cannot store numeric label values
* [ ] The metric was converted into a distributed trace

> **Explanation:** Every unique label combination is a separate time series, so unbounded values such as user IDs or arbitrary paths create too many. Keep labels bounded and put per-request detail in restricted logs or traces.

#### Q. Which statement correctly distinguishes an SLI from an SLO?

* [ ] An SLI is a contract penalty; an SLO is a dashboard panel
* [x] An SLI measures a result; an SLO sets its target and window
* [ ] An SLI is set by customers; an SLO is set by the provider
* [ ] An SLI covers latency only; an SLO covers availability only

> **Explanation:** A service-level indicator measures a result, such as the fraction of valid requests that succeed. A service-level objective sets the target for that indicator over a time window, such as 99.9% over 30 days.

#### Q. A service has a 99.9% request-success SLO over 30 days and receives 2,000,000 eligible requests in that window. How many failed requests does the error budget allow?

* [ ] 200
* [x] 2,000
* [ ] 20,000
* [ ] 1,998,000

> **Explanation:** The error budget is the allowed failure fraction, 0.1%, of eligible requests: 0.001 × 2,000,000 = 2,000. Define which requests are eligible and what counts as success before calculating.

#### Q. Which situation justifies paging an on-call engineer immediately?

* [ ] A disk will reach 80% capacity in about three weeks
* [x] Checkout failures are rising and customers are affected
* [ ] A nightly report job ran five minutes slower than usual
* [ ] A dependency released a new minor version upstream

> **Explanation:** Page someone when timely action is needed for a significant service impact. Slower capacity and maintenance issues belong in tickets or scheduled review.

#### Q. Errors spike right after a deployment. The cause is not yet understood. What is the best first mitigation?

* [x] Stop or roll back the rollout using a known procedure
* [ ] Debug in production until the root cause is confirmed
* [ ] Change several configuration settings at the same time
* [ ] Delete the logs from the period to reduce the noise

> **Explanation:** Mitigate with a known action, such as stopping a rollout, before completing the investigation. Preserve evidence and avoid changing several unrelated things at once, then verify recovery with user-facing signals.

#### Q. A user signs in successfully with a valid token, then tries to delete another team's project. Which control should stop the request?

* [ ] Authentication, since the token proves who the user is
* [x] Authorization, which decides what that identity may do
* [ ] TLS, which encrypts the request on its way to the server
* [ ] Network reachability, since the user reached the endpoint

> **Explanation:** Authentication establishes an identity; authorization determines what it may do. Network reachability and encryption are not proof that a request should be accepted.

#### Q. A cloud role has narrow permissions, but its trust policy allows any principal in the account to assume it. Why is this a problem?

* [ ] Trust policies only matter for roles used by humans
* [x] The trust policy decides who may assume the role at all
* [ ] Narrow permissions are ignored when trust is broad
* [ ] A role cannot have both permissions and a trust policy

> **Explanation:** Restrict role trust as well as permissions. The permissions say what the role can do, while the trust policy says who may assume it, so broad trust lets unintended identities gain those permissions.

#### Q. An API token was pasted into a public chat channel. What is the correct first action?

* [ ] Delete the message and assume the token is now safe
* [x] Revoke or replace the token, then investigate its use
* [ ] Rewrite Git history to remove any copies of the token
* [ ] Ask channel members to confirm they did not copy it

> **Explanation:** Removing a secret from its current location does not invalidate copies in logs, caches or history. Revoke or replace it first, investigate how it was used, and plan any cleanup afterwards.

#### Q. A team plans to rotate a database password every 90 days. What should they test before relying on rotation?

* [ ] That the new password is longer than the old one
* [x] That dependent services reload it without an outage
* [ ] That the password appears in the deployment logs
* [ ] That the old password stays valid after rotation

> **Explanation:** Document who owns each secret, how applications reload it and how to replace it, then test rotation with the dependent services so a credential change does not cause an outage.

#### Q. Which test verifies that an access boundary actually works?

* [ ] Confirm the restricted role can perform its normal tasks
* [x] Confirm the restricted role is denied an action outside it
* [ ] Confirm the role's policy document is valid JSON
* [ ] Confirm the role appears in the account's role list

> **Explanation:** A boundary is proven by a denied request, not by successful normal work. Also test that expired credentials stop working and that important administrative actions are logged.

#### Q. A team moved PostgreSQL from port 5432 to 6543 and renamed the admin user, calling the database "secured." What is wrong with this reasoning?

* [ ] Port 6543 is reserved and will conflict with other services
* [ ] PostgreSQL only accepts TLS connections on port 5432
* [x] It does not replace network controls and authentication
* [ ] Renaming the admin user disables password authentication

> **Explanation:** Changing a default port or username does not replace network controls and authenticated connections. Keep the database reachable only by clients that need it, use TLS with verification and give each client a separate least-privilege identity.

#### Q. A query has become slow as a table grew. Someone proposes upgrading to a larger database instance. What should come first?

* [ ] Double the connection pool size for the application
* [x] Review the slow query log and the query's execution plan
* [ ] Add an index on every single column that the table contains
* [ ] Restart the database to clear its memory caches

> **Explanation:** Review slow queries and execution plans before assuming the answer is a larger instance. A missing index or an unbounded query is a common cause, and indexes also add storage and write cost, so add them deliberately.

#### Q. You need to rename the column `fullname` to `display_name` while old and new application versions run together. Which sequence follows expand-and-contract?

* [ ] Rename `fullname` in one migration, then deploy code using the new name
* [ ] Drop `fullname`, add `display_name`, then redeploy every version at once
* [x] Add `display_name`, write both, backfill, switch reads, drop `fullname`
* [ ] Deploy code reading only `display_name`, then add and backfill the column

> **Explanation:** Expand-and-contract adds a compatible field, deploys code that can use it, backfills safely, switches reads, and removes the old field only after older versions no longer depend on it. A direct rename breaks the version still running.

#### Q. A migration converts prices from cents to rounded whole currency units. The team says, "we can always run the down migration." Why is that unsafe?

* [ ] Down migrations can only run on the primary replica
* [x] The transformation loses data, so it may not reverse
* [ ] Down migrations are always applied automatically
* [ ] Rounding is reversed when the column type changes

> **Explanation:** Not every migration has a lossless inverse. Dropping a column or transforming data can be irreversible, so write a recovery strategy for risky changes, which may mean fixing forward or restoring data.

#### Q. A database has a synchronous replica in another zone. Someone runs `DELETE FROM orders;` by mistake. What does the replica provide?

* [ ] A clean copy of the orders from before the delete
* [x] Nothing for this case, since it copies the delete too
* [ ] An automatic rollback of the transaction on the primary
* [ ] A frozen snapshot of the table taken at the last hour

> **Explanation:** Replication across failure domains reduces downtime but also copies accidental deletion or corruption. High availability and backups solve different problems, so the orders must come from a protected backup or point-in-time recovery.

#### Q. A shop can lose at most 15 minutes of orders and must be serving again within one hour after a failure. How are these targets expressed?

* [x] RPO of 15 minutes, RTO of one hour
* [ ] RTO of 15 minutes, RPO of one hour
* [ ] SLO of 15 minutes, SLI of one hour
* [ ] RPO and RTO both set at one hour

> **Explanation:** The recovery point objective is the acceptable data loss measured in time, and the recovery time objective is how long restoration may take. Both must be met: recent enough data and a restore that fits within an hour.

#### Q. A service has an RPO of 15 minutes, but its only database backup runs nightly at 02:00. What is the gap?

* [ ] The RTO is too short for a nightly backup to restore
* [x] Up to about 24 hours of data could be lost
* [ ] Nightly backups always meet any RPO under one day
* [ ] The backup must also be copied to a second region

> **Explanation:** With only nightly backups, a failure just before the next backup loses almost a day of writes, far beyond 15 minutes. Meeting the RPO needs more frequent recovery points, such as continuous log archiving or point-in-time recovery.

#### Q. A team keeps its production data plus two backup copies, on two different storage types, with one copy off-site. Which rule does this follow?

* [ ] The 2-1-0 rule
* [x] The 3-2-1 rule
* [ ] The 1-1-1 rule
* [ ] The 3-3-3 rule

> **Explanation:** The 3-2-1 rule means three copies of data, on two different media or storage types, with one copy off-site. It keeps copies separate from the original failure domain; many teams also add an immutable or offline copy.

#### Q. The backup job has reported success every night for a year. What actually proves the backups are usable?

* [ ] The job's exit code and the size of each backup file
* [x] Restoring one into a separate environment and testing it
* [ ] Confirming the backup bucket has versioning enabled
* [ ] Checking that backups are encrypted with a current key

> **Explanation:** A backup is useful only if the service can be restored from it within the required time and data loss. Restore into a separate environment, validate data and workflows, and measure the elapsed time and data gap.

#### Q. An engineer backs up a busy database by copying its data directory with `cp -r` while the server runs. What is the risk?

* [ ] The copy will be too large to compress efficiently
* [x] The copied files may not form a consistent database
* [ ] The database will lose its data directory after copying
* [ ] The copy will include the database's TLS private key

> **Explanation:** A filesystem copy of live database files may capture them mid-write and not be a usable backup. Use the engine's backup tools or a consistent snapshot mechanism, and verify by restoring.

#### Q. During a restore drill of production data into a test environment, what should be disabled?

* [ ] Database authentication for the restored copy
* [x] Destructive or externally visible background jobs
* [ ] Monitoring and logs for the test environment
* [ ] The backup schedule for the production database

> **Explanation:** A restored copy can contain scheduled jobs that send emails, charge cards or delete data. Keep destructive or externally visible jobs disabled during drills, and coordinate writes and traffic during a real cutover.

#### Q. On Amazon RDS, you run point-in-time recovery to 09:58, just before a bad deletion at 10:00. What happens?

* [ ] The existing instance is rewound in place to 09:58
* [x] A new instance is created with data as of 09:58
* [ ] Only the deleted rows are copied back into the table
* [ ] The application is reconnected to the restored data

> **Explanation:** RDS point-in-time recovery creates a new DB instance. Validating it, reconnecting the application and switching traffic are extra steps, and writes after 09:58 may need reconciliation.

#### Q. A small company's servers were configured by hand over several years. What should happen before broad configuration changes?

* [ ] Move every server into Kubernetes in one project
* [x] Inventory the servers and confirm a restore works
* [ ] Reinstall every server from the same new OS image
* [ ] Write an Ansible role covering every possible setting

> **Explanation:** Record each server's purpose, owner, services, dependencies, jobs and data locations, and back up and test a restore before changing things. Then automate one low-risk task and expand gradually.

#### Q. An Ansible playbook is run a second time against the same host with no changes in between. What indicates its tasks are idempotent?

* [ ] Every task reports `changed` on both runs
* [x] The second run reports no new changes
* [ ] The second run is skipped by Ansible automatically
* [ ] The playbook fails if the host is already configured

> **Explanation:** An idempotent task converges on the desired state and does not report a change when it is already there. Prefer modules that describe the desired state over shell commands that run unconditionally.

#### Q. A playbook is run with `--check --diff` and shows the expected changes. What does this not guarantee?

* [x] That the application works after the change
* [ ] That the playbook syntax could be parsed
* [ ] That the inventory targets could be reached
* [ ] That Ansible computed a predicted result

> **Explanation:** Check and diff modes help review changes, but support depends on the module, and neither proves the application will work. Diffs may also expose secrets, so review where the output goes.

#### Q. A playbook changes the SSH configuration on 40 servers. Which rollout is safest?

* [ ] Apply it to all 40 servers at once so they stay consistent
* [ ] Apply it by hand on each server, then update the playbook
* [x] Keep a recovery path, change a small batch, verify, expand
* [ ] Disable password access everywhere before testing the keys

> **Explanation:** Roll out to a small batch, verify health and stop on failure. When changing SSH, firewall or admin settings, keep a recovery access method so a failed rollout does not lock everyone out.

#### Q. A team moves a scheduled cleanup into a Kubernetes CronJob with overlapping runs forbidden. Is the cleanup now guaranteed to run exactly once per schedule?

* [ ] Yes, forbidding overlap guarantees exactly-once runs
* [x] No, so the job should still be idempotent or locked
* [ ] Yes, as long as the CronJob has only one replica
* [ ] No, CronJobs always run once per node in the cluster

> **Explanation:** A CronJob can limit overlapping jobs from the same CronJob, but scheduling is not an exactly-once guarantee; runs can be missed or repeated. Use idempotency or locking where duplicate work would be harmful.

#### Q. A monolith runs behind a load balancer with three replicas, all using one database on a single unprotected host. How available is the service?

* [ ] Highly available, because there are three replicas
* [ ] Highly available, because the load balancer reroutes
* [x] Limited by the database, a single point of failure
* [ ] Limited by the monolith, which cannot be replicated

> **Explanation:** Multiple replicas help only when shared dependencies support them. A load balancer cannot make a single unprotected database highly available. A monolith can be packaged and replicated reliably.

#### Q. A team wants to rebuild a model from six months ago. They have the training code commit. What else must have been recorded?

* [ ] Only the Python interpreter version used for serving
* [x] The dataset version, features, parameters and seeds
* [ ] Only the evaluation score reported to stakeholders
* [ ] The name of the engineer who trained the model

> **Explanation:** Model behavior depends on code, data, features and training configuration. Record the dataset version or immutable reference, feature transformations, parameters, dependencies, random seeds and evaluation results with the artifact.

#### Q. A model scores well offline, but in production its predictions are poor because the serving code computes a feature differently from the training pipeline. What is this called?

* [ ] Concept drift
* [ ] Data leakage
* [x] Training-serving skew
* [ ] Label shift

> **Explanation:** Training-serving skew is a difference between feature processing during training and inference. Concept drift is a change in the relationship between inputs and outcomes, and data leakage is test information contaminating training.

#### Q. A fraud model's input distribution is unchanged, but fraudsters have adopted new tactics, so the same inputs now indicate different outcomes. What is this?

* [ ] Data drift
* [x] Concept drift
* [ ] Training-serving skew
* [ ] A schema change

> **Explanation:** Concept drift is a change in the relationship between inputs and the intended outcome. Data drift is a change in the input distribution, which can occur without predictions getting worse.

#### Q. A model's overall accuracy is 94%, but complaints come from one customer region. What practice would have exposed this before release?

* [ ] Reporting only the overall accuracy to more decimal places
* [x] Recording evaluation slices that matter to the application
* [ ] Training on the test set to increase overall accuracy
* [ ] Retraining automatically every night on all new data

> **Explanation:** An average score can hide poor performance for a particular group or scenario. Record evaluation slices that matter, and keep training, validation and test data separate to avoid leakage.

#### Q. A team wants to see how a candidate model behaves on real production inputs without affecting any user decisions. Which approach fits?

* [x] Shadow traffic sent to the candidate model
* [ ] A controlled experiment that serves both models
* [ ] Automatic promotion after nightly retraining
* [ ] Replacing the current model during low traffic

> **Explanation:** Shadow traffic reveals serving behavior without affecting user decisions, while a controlled experiment measures product impact by exposing users to the candidate. Both need care around load and privacy.
