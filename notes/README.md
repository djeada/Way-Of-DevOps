# Notes

Follow the groups below in order for a first pass. Each note covers one topic and links to related material. Start with a working application; use the [labs](../labs/README.md) to make the concepts concrete.

## Foundations

- [Linux and scripting](linux_and_scripting.md): files, processes, services, Git, and repeatable scripts.
- [Networking and HTTP](networking.md): DNS, TCP/UDP, TLS, routing, and troubleshooting.
- [Virtual machines and VirtualBox](virtualbox.md): hypervisors, network modes, snapshots, and disposable environments.
- [Inter-process communication](ipc.md): pipes, Unix sockets, network sockets, and message queues.

## Delivery

- [How a full-stack application reaches the cloud](full_stack_app_with_cloud.md): source code, pipelines, cloud accounts, and customer requests.
- [CI/CD](ci_cd.md): builds, deployment gates, release strategies, and recovery.
- [Continuous integration](continuous_integration.md): fast feedback and meaningful checks.
- [GitHub Actions](github_actions.md): workflow concepts and a runnable repository example.
- [Canary releases](canary_release.md): gradual exposure, measurements, and stopping rules.
- [GitOps](git_ops.md): versioned desired state and continuous reconciliation.

## Infrastructure

- [Cloud fundamentals](cloud.md): service models, regions, identity, networking, and cost.
- [Google Cloud architecture](gcp_cloud_architecture.md): resource hierarchy, IAM, networking, compute and data choices, reliability, security, cost, and migration, organised around the Professional Cloud Architect exam.
- [Terraform and infrastructure as code](terraform_and_iac.md): plans, state, modules, and drift.
- [Choosing infrastructure tools](intro_to_tools.md): provisioning, configuration, images, and orchestration.
- [Containers and orchestration](containers_and_orchestration.md): images, persistent data, Compose, and Kubernetes.

## Operations

- [Observability and incidents](observability.md): metrics, logs, traces, service objectives, and response.
- [Security and secrets](security_and_secrets.md): access boundaries, credentials, and software dependencies.
- [Database operations](best_practices.md): access, performance, migrations, and availability.
- [Backup and recovery](backup_and_recovery.md): recovery objectives, protected copies, and restore drills.

## Applying the ideas

- [Managing servers in a small company](server_in_small_company.md): introduce configuration management in small steps.
- [Moving from manual operations to repeatable systems](modern_vs_old.md): improve an existing service without a full rewrite.
- [MLOps fundamentals](mlops.md): reproducible models, data validation, and production feedback.

The older [continous_integration.md](continous_integration.md) address points to the correctly spelled continuous integration note so existing links remain usable.
