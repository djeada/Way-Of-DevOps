# DevOps Flashcards

Review cards for the DevOps notes: foundations, delivery, infrastructure and operations. Each answer is short enough to recall in one go; follow the notes for detail.

## Linux and scripting

<details>
<summary>Which questions should you answer before changing a running Linux service?</summary>

Which process owns the listener, which user runs it, where its configuration comes from, where its logs go, and what survives a restart. On systemd hosts, `systemctl` inspects the unit and `journalctl -u <unit>` shows its logs.

</details>

<details>
<summary>What is the difference between `git diff` and `git diff --cached`?</summary>

`git diff` shows unstaged changes: the working tree compared with the staging area. `git diff --cached` shows staged changes compared with the last commit, which is what `git commit` would record. Check both before committing.

</details>

<details>
<summary>Why use `git revert` rather than `git reset` to undo a commit on a shared branch?</summary>

`git revert` records a new commit with the inverse change, so history others have already pulled stays intact. `git reset` followed by a force push rewrites shared history and disrupts every other clone.

</details>

<details>
<summary>A secret was committed and later deleted and added to `.gitignore`. Is it safe?</summary>

No. Earlier commits, clones, logs and caches still contain it, and `.gitignore` only affects untracked files. Revoke or replace the secret first, investigate its use, then plan history cleanup separately.

</details>

<details>
<summary>What does `set -euo pipefail` do in a Bash script?</summary>

- `-e`: exit when a command fails (with exceptions in conditionals and some control flow).
- `-u`: treat expansion of unset variables as an error.
- `-o pipefail`: a pipeline fails if any command in it fails, not just the last.

It does not replace explicit handling of expected errors.

</details>

<details>
<summary>What makes a script safe to rerun?</summary>

It produces the same end state each time: for example, `mkdir -p` succeeds if the directory exists, and output files are overwritten rather than appended. Inputs, required tools, side effects and outputs are explicit, expansions are quoted, and failure paths are checked. Test on a disposable target first.

</details>

## Networking and HTTP

<details>
<summary>In what order should you troubleshoot a failing web request?</summary>

Name resolution, then routing, then connection establishment, then TLS, then the HTTP application. A failure at one layer prevents the later layers from running, so start at the first one that fails.

</details>

<details>
<summary>"Connection refused" versus a timeout: what does each usually suggest?</summary>

A refusal is an active answer, usually meaning no listener on that address and port or an explicit rejection. A timeout can come from filtering, routing, an unavailable peer or a stalled application. Neither is diagnosed by ping, which only tests ICMP.

</details>

<details>
<summary>How do TCP and UDP differ?</summary>

TCP provides an ordered byte stream with retransmission. UDP provides individual datagrams with no built-in delivery or ordering guarantees; applications add what they need. HTTP/1.1 and HTTP/2 commonly use TCP, and HTTP/3 uses QUIC over UDP.

</details>

<details>
<summary>What does TLS protect, and what does it not decide?</summary>

TLS authenticates the server through certificate validation (chain, expiry, hostname) and protects data in transit. It does not decide whether an authenticated user may access a particular record; that is application authorization.

</details>

<details>
<summary>What do 4xx and 5xx status codes generally indicate?</summary>

4xx usually describes a client-side request or access problem, such as 404 Not Found or 401 Unauthorized. 5xx indicates a server-side failure along the serving path, such as 502 Bad Gateway from a proxy whose upstream is down. Check which component generated it.

</details>

<details>
<summary>When is it safe to retry a request automatically?</summary>

When repeating the work is safe, such as an idempotent read. Use timeouts, a retry limit and backoff. For state-changing requests like payments, use an idempotency key with server-side deduplication so a repeat does not apply twice.

</details>

## Virtual machines

<details>
<summary>What is the difference between a type 1 and a type 2 hypervisor?</summary>

A type 1 hypervisor runs directly on hardware (VMware ESXi, Microsoft Hyper-V). A type 2 hypervisor runs on a host operating system; VirtualBox is commonly described this way.

</details>

<details>
<summary>Compare the VirtualBox NAT, bridged, host-only and internal network modes.</summary>

- NAT: outbound access; inbound usually needs port forwarding.
- Bridged: the guest appears on the physical network and may be reachable by other devices.
- Host-only: private network between host and guests, no external access through it.
- Internal: guests talk to each other only; no host or external access through it.

Every enabled adapter adds reachability, so check them all.

</details>

<details>
<summary>Why is a VM snapshot not a backup?</summary>

A snapshot depends on the VM's own storage chain, so losing those files loses the snapshot too. Reverting also discards everything since it was taken. Keep important work and backups outside the disposable guest.

</details>

## Inter-process communication

<details>
<summary>When would you choose a Unix-domain socket over a TCP socket?</summary>

When both processes run on the same host, such as a reverse proxy and its application. It avoids exposing a TCP listener, and file ownership and permissions restrict access. It still needs authorization, and container mounts affect who can reach it.

</details>

<details>
<summary>Why does a TCP protocol need message framing?</summary>

TCP is a byte stream: one write does not guarantee one read, so messages can be split or joined. Define boundaries with length prefixes, delimiters or an established protocol, and set timeouts and size limits.

</details>

<details>
<summary>When should a queue consumer acknowledge a message?</summary>

Only after the intended result is safely recorded. Brokers may redeliver, for example after a crash before acknowledgment or when an SQS visibility timeout expires, so consumers must be idempotent or deduplicate work.

</details>

## CI/CD and continuous integration

<details>
<summary>How do continuous integration, continuous delivery and continuous deployment differ?</summary>

- CI: small changes are integrated frequently and checked automatically.
- Continuous delivery: every passing change produces a deployable artifact; production can wait for approval.
- Continuous deployment: every change that passes the required checks goes to production automatically.

CI does not require production access.

</details>

<details>
<summary>What does "build once, promote the same artifact" mean, and why does it matter?</summary>

Build a versioned artifact once, record its digest, and deploy that exact artifact to test, staging and production, with environment configuration kept separate. Rebuilding per environment can produce something different from what was tested.

</details>

<details>
<summary>Compare rolling, blue/green and canary releases.</summary>

- Rolling: replace instances in batches; old and new versions coexist.
- Blue/green: prepare a second environment and switch traffic; needs extra capacity and shared-data compatibility.
- Canary: expose a small cohort first; needs representative traffic and reliable stopping signals.

</details>

<details>
<summary>When does an application rollback work?</summary>

When the previous artifact is still available and the older version can read the current data and configuration. Backward-compatible migrations keep that true. Restoring a database to an earlier time is disaster recovery that can discard later writes, not routine rollback.

</details>

<details>
<summary>What is the difference between a CI cache and a release artifact?</summary>

A cache (such as downloaded dependencies) only speeds up jobs; a miss should change timing, never results. A release artifact is the versioned output that is published and promoted between environments.

</details>

<details>
<summary>Why is a high coverage percentage not proof of good tests?</summary>

Coverage shows which code ran during tests, not whether the tests assert meaningful behavior or catch failures. Test important behavior and failure paths, and review any threshold as the code changes.

</details>

## GitHub Actions

<details>
<summary>How do jobs and steps differ in a GitHub Actions workflow?</summary>

Steps within a job run in order on the same runner and share its filesystem. Jobs run independently, often on separate runners, unless `needs` declares a dependency; they exchange files through artifacts or other explicit storage.

</details>

<details>
<summary>Why is `pull_request_target` dangerous with untrusted code?</summary>

It runs in the base repository's context, with access to secrets and a write-capable token. Checking out and running a contributor's code there (including install and test scripts) hands those privileges to that code.

</details>

<details>
<summary>How do you safely use a pull request title in a `run:` step?</summary>

Pass it through an `env:` variable and quote that variable in the script. Interpolating `${{ github.event.pull_request.title }}` directly into the script text lets a crafted title inject shell commands.

</details>

<details>
<summary>Why pin third-party actions to a full commit SHA?</summary>

Tags are mutable and can be moved to different code. A reviewed full commit SHA identifies fixed content; update pins deliberately.

</details>

<details>
<summary>What does `id-token: write` allow, and what limits it?</summary>

It allows a job to request an OIDC identity token. The cloud provider's trust policy decides which workflows may exchange that token for a role, and the role's permissions limit what it can do. It replaces long-lived access keys.

</details>

## Canary releases

<details>
<summary>What must be decided before starting a canary?</summary>

The stable baseline, the initial cohort, the measurements (error rate, latency, resource use, a product signal), the observation window, and the stopping rules. Keep enough stable capacity to take traffic back.

</details>

<details>
<summary>What are the limits of a canary release?</summary>

It reduces exposure while evidence is collected but cannot guarantee safety for rare failures, destructive data changes, or background jobs that bypass the traffic split. Both versions must also work with the same data and messages.

</details>

## GitOps

<details>
<summary>What are the four OpenGitOps principles?</summary>

Desired state is declarative, versioned and immutable (with history), pulled automatically by agents, and continuously reconciled with the actual state.

</details>

<details>
<summary>What is drift in GitOps, and how should emergency changes be handled?</summary>

Drift is a difference between the declared configuration and the running system; the controller reports or corrects it according to policy. Emergency manual changes must be captured in the source of truth, or reconciliation may undo them.

</details>

<details>
<summary>What does reverting a GitOps configuration commit not do?</summary>

It does not undo database writes, restore deleted data, or prove the earlier application supports the current schema. Verify health after reconciliation and use the recovery plan for data loss.

</details>

## From source code to cloud

<details>
<summary>How should browser code get access to cloud storage?</summary>

Never with the server's cloud credentials. The server can issue a limited mechanism such as a signed URL with explicit authorization and expiry. Website customers have application identities, not cloud IAM users.

</details>

<details>
<summary>How do authentication and permission differ for a workload calling a cloud API?</summary>

Authentication proves the identity (for example, a workload role or OIDC-federated CI job). Permission decides what it may do; a valid identity can still be denied by its policies, resource policies, network rules or database authentication.

</details>

## Cloud fundamentals

<details>
<summary>What do you manage under IaaS, PaaS and SaaS?</summary>

- IaaS: the guest OS and application on provider VMs and networks.
- PaaS: application behavior, data, configuration and access; the provider runs more of the runtime.
- SaaS: configuration and use of a finished application.

Serverless still has quotas, failure modes, costs and configuration.

</details>

<details>
<summary>What is the difference between a region and an availability zone?</summary>

A region is a geographic deployment area. Availability zones are separate locations within a region that limit the impact of some failures. Multiple zones improve availability; multiple regions add decisions about replication, routing and recovery.

</details>

<details>
<summary>Compare block, file and object storage.</summary>

- Block: disks attached to a machine.
- File: shared filesystems mounted by several machines.
- Object: objects addressed by key over an API, suited to uploads and static assets.

</details>

<details>
<summary>Does a cloud budget alert stop spending?</summary>

Generally not; it notifies people when spending crosses a threshold rather than enforcing a hard limit. Combine it with ownership tags and reviews of idle resources, egress and logging costs.

</details>

## Terraform and IaC

<details>
<summary>What is the Terraform working cycle?</summary>

Write configuration with pinned provider and module versions, run `terraform init`, check with `terraform fmt -check` and `terraform validate`, run `terraform plan -out=tfplan`, review it, then `terraform apply tfplan`. Confirm the account and environment first.

</details>

<details>
<summary>Why is Terraform state treated as sensitive operational data?</summary>

State maps resource addresses to real objects and can contain credentials, even for outputs marked `sensitive`. Store it in a remote backend with access controls, encryption, versioning and locking, and keep it and saved plans out of Git.

</details>

<details>
<summary>What does removing a resource from Terraform state do?</summary>

It stops Terraform managing the object; it does not delete the remote resource. To adopt or refactor resources, use supported import and move mechanisms instead of editing state JSON.

</details>

<details>
<summary>Do Terraform CLI workspaces separate environments securely?</summary>

They separate state instances but do not create an access-control boundary. Give environments separate state and credential boundaries, and avoid one large state shared by unrelated teams.

</details>

## Choosing infrastructure tools

<details>
<summary>Which tool category handles each lifecycle stage?</summary>

- Provision infrastructure: Terraform, CloudFormation.
- Build machine images: Packer.
- Configure an OS: Ansible, Puppet, Chef, Salt.
- Build and run containers: Docker, Podman.
- Orchestrate containers: Kubernetes.
- Coordinate delivery: GitHub Actions, Jenkins, GitLab CI.
- Reconcile desired state: Argo CD, Flux.

</details>

<details>
<summary>Why must two controllers not own the same setting?</summary>

They overwrite each other continually, for example Terraform resetting an instance count that an autoscaler changed. Define which tool owns each setting and which differences are expected.

</details>

## Containers and orchestration

<details>
<summary>How does a container differ from a VM?</summary>

A container is an isolated process environment that shares the kernel of its runtime environment. A VM runs its own guest kernel on virtual hardware. Containers are not limited to one process, though separating responsibilities helps.

</details>

<details>
<summary>Why record an image digest instead of a tag for a release?</summary>

A tag can be reassigned to a different image, so it is not a fixed artifact identity. The digest identifies exact content and makes the release reproducible.

</details>

<details>
<summary>What happens to data written inside a container's writable layer?</summary>

It disappears when the container is removed. Use a volume or an external service for databases and uploads, and back that storage up; a volume is not a backup.

</details>

<details>
<summary>Compare readiness, liveness and startup probes.</summary>

- Readiness: whether the workload should receive traffic.
- Liveness: whether to restart it.
- Startup: gives a slow-starting app time before other probes apply.

A liveness probe that checks a dependency can turn its outage into repeated restarts.

</details>

<details>
<summary>What do a Kubernetes Deployment and Service each provide?</summary>

A Deployment manages a set of replicated Pods and rolls out updates. A Service selects Pods by label and gives them a stable name and address so clients do not track individual Pods.

</details>

## Observability and incidents

<details>
<summary>How do metrics, logs and traces differ?</summary>

Metrics summarize measurements over time (counts, latency distributions). Logs record individual events with context. Traces connect the operations of one request across several components.

</details>

<details>
<summary>What are SLIs, SLOs and error budgets?</summary>

An SLI measures a result, such as the fraction of valid requests that succeed. An SLO sets a target and window, such as 99.9% over 30 days. The error budget is the allowed shortfall: 1,000 failures per 1,000,000 eligible requests at 99.9%.

</details>

<details>
<summary>Why keep metric labels bounded?</summary>

Each distinct label combination creates a separate time series, so values like user IDs or arbitrary paths explode storage and cost. Put per-request detail in restricted logs or traces.

</details>

<details>
<summary>What are the steps of a small incident workflow?</summary>

Confirm impact and start time; assign coordination and investigation; mitigate with a known action such as stopping a rollout; verify recovery with user-facing evidence and communicate; record a timeline and follow-up actions with owners.

</details>

## Security and secrets

<details>
<summary>What is the difference between authentication and authorization?</summary>

Authentication establishes an identity. Authorization determines what that identity may do. Network reachability is not proof that a request should be accepted.

</details>

<details>
<summary>Why does a cloud role's trust policy matter as much as its permissions?</summary>

Permissions define what the role can do; the trust policy decides who may assume it. Broad trust lets unintended identities obtain even narrow permissions.

</details>

<details>
<summary>What lifecycle details should be documented for each secret?</summary>

Who owns it, how it is issued, how applications receive and reload it, and how to revoke or replace it. Test rotation with dependent services so a change does not cause an outage.

</details>

## Database operations

<details>
<summary>What is expand-and-contract for schema changes?</summary>

A way to change a schema while old and new versions coexist: add a compatible field, deploy code that can use it, backfill safely, switch reads, and remove the old field only after older versions no longer depend on it.

</details>

<details>
<summary>Why does a replica not replace backups?</summary>

Replication reduces downtime from hardware or zone failures, but it copies accidental deletion and corruption too. Backups provide an independent history to restore from.

</details>

## Backup and recovery

<details>
<summary>What do RPO and RTO mean?</summary>

Recovery point objective (RPO): the acceptable data loss, measured in time. Recovery time objective (RTO): how long restoration may take. An RPO of 15 minutes and RTO of one hour need recent recoverable data and a restore that fits within an hour.

</details>

<details>
<summary>What is the 3-2-1 backup rule?</summary>

Keep three copies of data, on two different storage types, with one copy off-site. It keeps copies out of the original failure domain; add immutable or offline copies when the threat model requires it.

</details>

<details>
<summary>What does a restore drill involve?</summary>

Pick a recovery point and its copies and keys, restore into a separate environment, validate data with a compatible app version, check workflows and integrations, measure recovery time and data gap, then document cutover and clean up. Keep destructive background jobs disabled.

</details>

<details>
<summary>How does point-in-time recovery differ from an application rollback?</summary>

A rollback deploys a previous artifact and keeps current data. Point-in-time recovery reconstructs data at an earlier time, so later writes may be lost; on Amazon RDS it creates a new instance that the application must be switched to.

</details>

## Gradual automation and modernisation

<details>
<summary>What does an idempotent Ansible task do on a second run?</summary>

It converges on the desired state and reports no new change when the host already matches. Prefer state-describing modules over shell commands that run unconditionally.

</details>

<details>
<summary>What should happen before automating a small company's servers?</summary>

Inventory each server's purpose, owner, services, dependencies, jobs and data, back up and confirm a restore, then automate one low-risk task on a test machine before expanding in small batches.

</details>

<details>
<summary>Why separate a web app from its scheduler before scaling?</summary>

Each web replica would run the scheduled task, so three replicas run a cron job three times. Run the scheduler or worker separately and design jobs to tolerate retries; even Kubernetes CronJobs are not exactly-once.

</details>

## MLOps

<details>
<summary>What must be recorded to reproduce a model?</summary>

Training code revision, dataset version or immutable reference, feature transformations, parameters, dependencies, random seeds and evaluation results, stored with the model artifact and its promotion history.

</details>

<details>
<summary>How do data drift, concept drift and training-serving skew differ?</summary>

- Data drift: the input distribution changes.
- Concept drift: the relationship between inputs and the intended outcome changes.
- Training-serving skew: features are processed differently in training and inference.

Input drift is a warning, not proof predictions got worse.

</details>

<details>
<summary>Why might rolling back a model require more than restoring the weights?</summary>

The model depends on compatible feature code and schema expectations. Retain a known-good artifact together with those, and define a fallback for when inference or input validation fails.

</details>
