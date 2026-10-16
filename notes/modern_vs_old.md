# Moving from manual operations to repeatable systems

An existing service can become easier to operate through a sequence of small changes. Start with the risks that make an incident hard to detect or recover from, then automate the work you can already explain.

## Establish a baseline

Inventory services, dependencies, versions, scheduled jobs, data, and access. Document a normal deployment and a recovery procedure. Collect basic health signals so you can compare behavior before and after a change.

Verify backups by restoring them into a separate environment. Monitoring and recovery are useful whether the application runs on bare metal, VMs, or containers. They should not wait for a platform migration.

## Make one environment reproducible

Put application and non-secret configuration in Git. Automate a small task with Ansible or another suitable tool, test it on a non-production machine, and then expand. Capture emergency repairs in the same source of truth.

Work toward rebuilding one application host from a documented base image and configuration. Decide whether existing hosts will be updated in place or replaced with newly built images. Keep persistent data separate from replaceable hosts.

Next, automate the build and deployment of a versioned application artifact. Retain the previous artifact and test both deployment verification and recovery. Add CI around the same commands developers use locally.

## Containerize when it helps

An image packages the application and its dependencies; containers share a kernel provided by the runtime environment. They are not full VMs and are not restricted to exactly one process, though separating responsibilities usually makes them easier to operate.

Identify files written at runtime, sessions, uploads, caches, secrets, and background workers before scaling the application. A monolith can be packaged and operated reliably. Splitting it into microservices is a separate architectural decision with additional coordination and failure modes.

For a web application with scheduled work, separate request handling from the scheduler or worker. Otherwise, running three web replicas might run a cron task three times. Design jobs to tolerate retries and duplicate attempts.

## Adopt orchestration deliberately

Multiple replicas help only when shared dependencies and application state support them. A load balancer cannot make a single unprotected database highly available. Define health checks, graceful shutdown, resource requirements, and data recovery before relying on automatic restarts.

Kubernetes can coordinate workloads when its capabilities justify the operating cost. A Kubernetes CronJob can limit overlapping jobs from the same CronJob, but scheduling is not an exactly-once guarantee. Use idempotency or locking where duplicate work would be harmful.

Do one production change at a time with a clear expected result and a way to stop. A useful milestone is being able to rebuild the service, restore its data, and explain a failure without depending on one person's memory.

Reference: [Kubernetes CronJobs](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/). Related: [containers and orchestration](containers_and_orchestration.md) and [small-company servers](server_in_small_company.md).
