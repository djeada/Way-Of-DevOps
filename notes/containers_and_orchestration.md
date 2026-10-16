# Containers and orchestration

A container image packages an application and its user-space dependencies. A container is a running instance of that image with process, filesystem, and resource isolation supplied by its runtime environment. Containers share that environment's kernel; a VM has its own guest kernel.

## Package the application

Build images from a versioned definition and known dependencies. Use a small maintained base image, exclude unnecessary build files, and keep secrets out of image layers. Multi-stage builds can keep compilers and build tools out of the final runtime image.

Run with a suitable non-root identity where practical, publish only needed ports, and give the workload explicit resource constraints. Record an immutable image digest for releases. A tag can be reassigned, so a tag alone is not a fixed artifact identity.

Separate runtime configuration from the image and deliver secrets through an appropriate mechanism. Write logs to a collected output stream, handle termination signals, and allow time to finish or abandon in-flight work cleanly.

## Keep state explicit

Files in a container's writable layer disappear when that container is removed. Use deliberate persistent storage or external services for databases and uploads. A volume keeps data beyond a container's lifetime, but it still needs backup and recovery.

Separate web requests, workers, and scheduled tasks when their lifecycles differ. Scaling web replicas should not accidentally duplicate a scheduler. Design workers for retries, use durable queues where needed, and avoid storing shared sessions only in one replica's memory.

## Compose and Kubernetes

Compose describes a group of services, networks, and volumes and is useful for a local environment or a small deployment. From a project with a `compose.yaml`, use `docker compose config` to inspect its resolved configuration, `docker compose ps` for status, and `docker compose logs` for output. Resolved configuration may contain secret values, so handle it accordingly.

Kubernetes adds scheduling and reconciliation across a cluster. Learn the purpose of a Pod, Deployment, Service, configuration and secret objects, persistent volumes, and Jobs or CronJobs. It can use compatible container runtimes without Docker Engine on the nodes.

A readiness probe controls whether a workload should receive traffic. A liveness probe can trigger a restart. A startup probe allows a slow-starting application time to initialize. A poorly chosen liveness probe can turn a dependency outage into repeated restarts.

## Operate the platform too

An orchestrator does not remove the need for node updates, access controls, storage recovery, networking, capacity planning, or diagnosis. Multiple replicas also need compatible data and dependencies to improve availability.

Start with a container that works locally, can stop gracefully, and exposes useful health signals. Add orchestration when the service and team need its scheduling, scaling, or rollout capabilities. See [choosing infrastructure tools](intro_to_tools.md) before adding a cluster.

References: [Docker container concepts](https://docs.docker.com/get-started/docker-concepts/the-basics/what-is-a-container/) and [Kubernetes concepts](https://kubernetes.io/docs/concepts/). Practice with the existing [container-based labs](../labs/README.md).
