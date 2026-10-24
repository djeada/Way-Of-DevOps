# DevOps Infrastructure Quiz

Notes: [Cloud fundamentals](../notes/cloud.md), [Terraform and infrastructure as code](../notes/terraform_and_iac.md), [Choosing infrastructure tools](../notes/intro_to_tools.md), [Containers and orchestration](../notes/containers_and_orchestration.md)

Check your understanding of cloud building blocks, Terraform state and plans, tool ownership, containers and Kubernetes.

#### Q. A team runs its application on IaaS virtual machines. Which task remains the team's responsibility?

* [ ] Replacing failed physical disks in the data center
* [x] Patching the guest operating system on each VM
* [ ] Cooling and powering the provider's server racks
* [ ] Maintaining the hypervisor that hosts the VMs

> **Explanation:** With IaaS the provider runs the physical infrastructure and virtualization, while you manage the guest operating system and application. PaaS shifts more of the runtime to the provider.

#### Q. A team moves its database to a managed PaaS database service. Which responsibility do they still own?

* [ ] Installing the database engine's binaries
* [ ] Replacing the underlying storage hardware
* [x] Deciding who may access the data and how
* [ ] Patching the host operating system kernel

> **Explanation:** PaaS manages more of the runtime or database, but you still own application behavior, data, configuration and access. The shared-responsibility split varies by service, so read it for each one.

#### Q. An application runs in two availability zones of one region. Which failure is it designed to tolerate?

* [ ] The loss of the entire region
* [x] An outage in one zone of the region
* [ ] Accidental deletion of its database
* [ ] A bug in the application release

> **Explanation:** Availability zones are separate locations within a region, so multiple zones limit the impact of some infrastructure failures. Surviving a regional outage needs multiple regions, and deletion or bad releases need backups and rollback.

#### Q. A subnet is named `private-app`, yet an instance in it is reachable from the internet. What determines whether it is actually public?

* [ ] The subnet's name and description tags
* [x] Its routes, public addresses and firewall rules
* [ ] The region where the subnet was created
* [ ] The availability zone's position in the list

> **Explanation:** A subnet's name does not determine reachability. Routes, public addressing, firewalls and service configuration do, so draw and verify the actual request path.

#### Q. An application needs to store user-uploaded images addressed by a key and served over HTTP. Which storage type fits best?

* [ ] Block storage attached to a single VM
* [ ] File storage shared over a network mount
* [x] Object storage that stores objects by key
* [ ] A local cache in the application's memory

> **Explanation:** Object storage stores objects addressed by key and is well suited to uploads and static assets. Block storage serves as a VM disk, and file storage provides shared filesystems.

#### Q. A team applies its production infrastructure template in a new account to create a staging copy. What will staging contain?

* [ ] All production data, copied by the template automatically
* [x] New, separate resources without production's data
* [ ] A read-only link to the production database
* [ ] The same resources, shared between both accounts

> **Explanation:** Reusing an infrastructure template creates a separate deployment; it does not copy the application's data. Use synthetic or sanitized data in non-production environments.

#### Q. A team sets a monthly budget alert for a learning account. What does the alert usually do when spending crosses the threshold?

* [ ] Stops every resource in the account at the limit
* [x] Notifies people about spending without stopping it
* [ ] Deletes the most expensive resource automatically
* [ ] Lowers the account's quotas to prevent more spend

> **Explanation:** Budget alerts generally report spending rather than enforcing a hard limit. Combine them with tags, ownership and regular review of idle resources, egress and logging costs.

#### Q. A nightly batch job can resume from checkpoints if it is stopped. Which compute pricing option suits it?

* [x] Interruptible (spot) capacity
* [ ] A three-year reserved commitment
* [ ] A dedicated single-tenant host
* [ ] The largest on-demand instance

> **Explanation:** Interruptible capacity suits workloads that tolerate termination. Reservations or commitments need a predictable demand forecast, which an occasional batch job does not provide.

#### Q. A Floci lab exercise succeeds against the local emulator. What does that prove about production AWS?

* [ ] Production IAM policies will behave identically
* [ ] Production will match the emulator's latency and timing
* [x] Little; emulator parity with production is not assured
* [ ] The same code is certified for compliance audits

> **Explanation:** Emulators are useful for learning AWS-style APIs, but they do not establish production service or IAM parity, timing or eventual-consistency behavior.

#### Q. `terraform validate` succeeds. What has it confirmed?

* [ ] The target account has permission to create the resources
* [ ] The cloud provider has capacity for every requested resource
* [x] The configuration is internally consistent and well-formed
* [ ] The plan will cost less than the project's monthly budget

> **Explanation:** Validation checks configuration consistency, not service availability, access rights, cost or every provider constraint. Those only surface during planning or applying against the real provider.

#### Q. A reviewer approved the output of `terraform plan -out=tfplan`. What happens when you run `terraform apply tfplan`?

* [ ] Terraform recalculates a fresh plan and asks for approval again
* [x] Terraform executes the saved plan without another approval prompt
* [ ] Terraform applies only the resources marked for creation
* [ ] Terraform discards the saved plan if any file was formatted

> **Explanation:** Applying a saved plan runs exactly those proposed actions without an interactive prompt, so review belongs before this step. Confirm the account, environment and workspace before planning.

#### Q. A plan output includes the following line for a database. What should the reviewer understand?

```text
  # aws_db_instance.main must be replaced
-/+ resource "aws_db_instance" "main" {
      ~ identifier = "orders-db" -> "orders-db-v2" # forces replacement
```

* [ ] Terraform will update the database in place with no downtime
* [ ] Terraform will skip the resource because nothing has changed
* [x] Terraform will destroy and recreate the database instance
* [ ] Terraform will only refresh the database's state attributes

> **Explanation:** `-/+` marks a replacement: the existing object is destroyed and a new one created (or the reverse with `create_before_destroy`). For persistent data, treat replacement and deletion actions very differently from updates.

#### Q. A colleague's `terraform apply` is running, and your plan fails because the state is locked. What should you do?

* [ ] Force-unlock the state so your plan can run immediately
* [ ] Copy the state file locally and plan against that copy
* [x] Wait for their operation to finish, then plan again
* [ ] Disable locking in the backend configuration permanently

> **Explanation:** Locking prevents concurrent writers from corrupting state. Coordinate writers and do not disable or bypass locking to get around another operation.

#### Q. A Terraform output is marked `sensitive = true`. Where can the value still be found?

* [ ] Nowhere, because Terraform encrypts it before storing
* [ ] Only in the provider's API, never on disk
* [x] In the state file, which must itself be protected
* [ ] Only in `.terraform.lock.hcl`, which must stay private

> **Explanation:** `sensitive` hides values from normal display but does not remove them from state or saved plans. Use a remote backend with access controls and encryption, and keep state and plans out of Git.

#### Q. Which Terraform file should be committed to version control?

* [ ] `terraform.tfstate`
* [ ] The saved `tfplan` file
* [x] `.terraform.lock.hcl`
* [ ] A `secrets.tfvars` file

> **Explanation:** Commit configuration and the provider dependency lockfile, `.terraform.lock.hcl`, so everyone uses the same provider versions. State, saved plans and secret variable files can contain sensitive values and stay out of Git.

#### Q. Someone runs `terraform state rm aws_s3_bucket.logs`. What happens to the real bucket?

* [ ] It is deleted on the next `terraform apply`
* [x] It keeps existing, but Terraform no longer manages it
* [ ] It is moved to a new address in the same state
* [ ] It is emptied of all objects but kept as a managed resource

> **Explanation:** Removing an object from state stops Terraform managing it; it does not delete the remote object. If the configuration still declares the bucket, a later plan would propose creating a new one.

#### Q. You rename a resource block from `aws_instance.web` to `aws_instance.app` without changing its settings. The plan wants to destroy and recreate it. What is the supported fix?

```hcl
resource "aws_instance" "app" {
  ami           = var.ami_id
  instance_type = "t3.small"
}
```

* [ ] Edit the state JSON by hand to change the address
* [x] Add a `moved` block from the old to the new address
* [ ] Run `terraform apply` and accept the replacement
* [ ] Delete `.terraform.lock.hcl` and run `init` again

> **Explanation:** Use supported move mechanisms, such as a `moved` block or `terraform state mv`, when refactoring addresses. Editing state JSON directly is an exceptional repair task that needs a backup and recovery plan.

#### Q. A team uses Terraform CLI workspaces named `dev` and `prod` in the same backend. What do the workspaces provide by themselves?

* [x] Separate state instances, but no access-control boundary
* [ ] Separate cloud accounts with distinct credential policies
* [ ] Automatic approval gates before any `prod` apply
* [ ] Encrypted state for `prod` but plain text for `dev`

> **Explanation:** CLI workspaces separate state instances but do not create an access-control boundary. Give environments separate state and appropriate credential boundaries, such as different backends and roles.

#### Q. A team hopes to apply its AWS network module unchanged to another cloud provider because both are managed with Terraform. Why will this fail?

* [ ] Terraform cannot manage more than one provider per project
* [x] Resources are provider-specific even with shared syntax
* [ ] Network resources cannot be placed in modules
* [ ] Modules can only be used once per Terraform version

> **Explanation:** Terraform can use many providers, but each provider's resources and arguments differ. A different cloud needs its own resource definitions, even if the module's inputs and structure look similar.

#### Q. An engineer changed a firewall rule in the console during an incident to stop an attack. The next plan proposes reverting it. What should happen?

* [ ] Apply the plan immediately so the configuration is authoritative
* [ ] Delete the rule from state so Terraform stops tracking it
* [x] Review the drift and update the configuration to keep the fix
* [ ] Destroy and recreate the firewall to clear the difference

> **Explanation:** Drift is a change outside the declared configuration and should be reviewed before accepting or correcting it. Blindly applying an old configuration can undo a necessary repair; reconcile the emergency change into the source of truth.

#### Q. A team must create a VM, then manage the packages, users and service configuration inside it. Which split of tools fits?

* [ ] Ansible creates the VM; Terraform manages the packages
* [x] Terraform provisions the VM; Ansible configures the OS
* [ ] Packer manages running VMs; Argo CD installs packages
* [ ] Docker creates the VM; Kubernetes manages its users

> **Explanation:** Terraform provisions infrastructure through provider APIs, but it does not generally enforce files and packages inside a VM. Configuration management such as Ansible handles the operating system, or Packer can bake those settings into an image.

#### Q. A team wants every new VM to start from a patched base image with their agent preinstalled. Which tool is designed for building that image?

* [x] Packer
* [ ] Argo CD
* [ ] Compose
* [ ] Flux

> **Explanation:** Packer builds machine images, often running scripts or Ansible during the build; Terraform can then deploy instances from the image. Argo CD and Flux reconcile cluster state, and Compose runs groups of containers.

#### Q. Terraform sets an instance group's size to 3, and an autoscaler raises it to 6 during peaks. Every plan proposes shrinking it back. What is the underlying problem?

* [ ] The autoscaler should be removed so Terraform is in control
* [x] Two controllers own the same setting without clear division
* [ ] Terraform's state is corrupted and should be deleted
* [ ] The instance group must be recreated on each apply

> **Explanation:** Do not let two controllers continually overwrite the same setting. Define ownership, for example letting the autoscaler own the count while Terraform ignores changes to it, and document which differences are expected.

#### Q. A small team runs one web app and a managed database, deployed by a repeatable script to a single VM. Someone proposes adopting Kubernetes. What should decide this?

* [ ] Kubernetes is required for any containerized application
* [ ] Kubernetes removes the need to manage node operating systems
* [x] Whether scheduling, scaling and rollout needs justify its cost
* [ ] Whether the cloud provider offers a free Kubernetes control plane

> **Explanation:** Kubernetes becomes useful when scheduling, scaling, isolation and rollout requirements justify operating the platform. Compare the cost of running and learning a tool with the manual work it removes.

#### Q. Do Kubernetes nodes need Docker Engine installed to run container images?

* [ ] Yes, Kubernetes can only start containers through Docker Engine
* [x] No, nodes can use any compatible container runtime
* [ ] Yes, but only for images built with a `Dockerfile`
* [ ] No, Kubernetes runs images as virtual machines instead

> **Explanation:** Kubernetes uses compatible container runtimes, such as containerd or CRI-O, through its runtime interface. Images built with Docker follow the OCI format and run without Docker Engine on the nodes.

#### Q. How does a container differ from a virtual machine?

* [ ] A container has its own guest kernel; a VM shares the host's
* [x] Containers share a kernel; a VM runs its own guest kernel
* [ ] A container always runs exactly one process; a VM runs many
* [ ] Containers need a type 1 hypervisor; VMs need a type 2 one

> **Explanation:** A container is an isolated process environment that shares the kernel of its runtime environment, while a VM has its own guest kernel on virtual hardware. Containers are not restricted to exactly one process.

#### Q. A PostgreSQL container stores data in its writable layer. The container is removed and recreated from the same image. What happens to the data?

* [ ] It is restored from the image's previous layer automatically
* [x] It is lost, because the writable layer goes with the container
* [ ] It is preserved, because the image tag has not changed
* [ ] It is moved into a volume that Docker creates on removal

> **Explanation:** Files in a container's writable layer disappear when the container is removed. Use a volume or an external service for persistent data, and still back it up, since a volume alone is not a backup.

#### Q. A Dockerfile copies `credentials.json` in one step and deletes it in a later `RUN` step. Is the secret gone from the image?

* [ ] Yes, deleting the file removes it from every layer
* [x] No, it remains in the earlier layer of the image
* [ ] Yes, as long as the image is pushed with a new tag
* [ ] No, but only if the image runs as the root user

> **Explanation:** Each instruction creates a layer, and a later deletion only hides the file in the final filesystem. Keep secrets out of image layers and deliver them at runtime; multi-stage builds help keep build-time files out of the final image.

#### Q. Why use a multi-stage Docker build for a compiled application?

* [x] The final image can omit compilers and build tools
* [ ] The image can run on hosts that lack a container runtime
* [ ] Each stage receives its own kernel at runtime
* [ ] The build no longer needs a pinned base image

> **Explanation:** A multi-stage build compiles in one stage and copies only the needed outputs into a small runtime stage, reducing image size and attack surface. It does not change how containers use the host kernel.

#### Q. During a rolling update, old containers are killed abruptly and users see failed requests. Which application change helps most?

* [ ] Writing logs to a file inside the container
* [ ] Running the application as the root user
* [x] Handling `SIGTERM` to finish in-flight requests
* [ ] Using the `latest` tag for every release

> **Explanation:** Orchestrators send a termination signal before killing a container. Handling it to stop accepting new work and finish or abandon in-flight work cleanly, within the grace period, avoids dropped requests.

#### Q. A web application with a built-in scheduler is scaled from one to three replicas. What new problem is likely?

* [ ] The scheduler stops running because replicas share a port
* [x] Each replica runs the scheduled task, so it runs three times
* [ ] The load balancer routes all requests to a single replica
* [ ] The image becomes three times larger to support replicas

> **Explanation:** Scaling web replicas should not accidentally duplicate a scheduler. Separate request handling from scheduled work and workers when their lifecycles differ, and design jobs to tolerate retries.

#### Q. A Pod is running but still warming its cache, and it should not receive traffic yet. Which probe controls this?

* [x] Readiness probe
* [ ] Liveness probe
* [ ] Restart policy
* [ ] Resource limit

> **Explanation:** A readiness probe decides whether a workload should receive traffic. A liveness probe can trigger a restart, and a startup probe gives slow-starting applications time to initialize before other probes apply.

#### Q. A liveness probe calls an endpoint that checks the database. During a database outage, every Pod restarts repeatedly. What was the mistake?

* [ ] The readiness probe should have been removed entirely
* [x] Liveness depended on an external dependency's health
* [ ] The Pods needed more replicas to survive the outage
* [ ] The database should have used a liveness probe too

> **Explanation:** A liveness failure restarts the container, and restarting does not fix the database. A poorly chosen liveness probe turns a dependency outage into repeated restarts; keep liveness about the process itself.

#### Q. In Kubernetes, which object gives a stable network address for a changing set of Pods managed by a Deployment?

* [ ] A ConfigMap
* [ ] A CronJob
* [x] A Service
* [ ] A PersistentVolume

> **Explanation:** A Deployment manages replicated Pods and rollouts, while a Service selects Pods by label and provides a stable name and address in front of them. ConfigMaps hold configuration, and PersistentVolumes provide storage.

#### Q. You run `docker compose config` to share the resolved configuration with a vendor. What should you check first?

* [ ] Whether the output includes every image's full layers
* [x] Whether it shows secret values from environment files
* [ ] Whether it will restart the running services
* [ ] Whether it deletes volumes listed in the file

> **Explanation:** `docker compose config` prints the resolved configuration, which may include values interpolated from environment variables or `.env` files. Handle it as potentially sensitive before sharing. It does not start, stop or delete anything.
