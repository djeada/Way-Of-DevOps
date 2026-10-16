# Cloud fundamentals

Cloud providers offer compute, storage, networking, and managed services through APIs. Learn one provider well enough to build and operate a small system before trying to memorize several service catalogs.

## Service models and responsibility

- Infrastructure as a service (IaaS) gives you resources such as virtual machines and networks. You manage the guest operating system and application.
- Platform as a service (PaaS) manages more of the runtime or database for you. You still own application behavior, data, configuration, and access.
- Software as a service (SaaS) delivers a finished application that you configure and use.

Serverless services manage capacity and execution infrastructure behind an API. They still have quotas, failure modes, costs, and configuration responsibilities. The provider's shared-responsibility model varies by service; a managed service does not remove the need to understand it.

## Concepts to learn first

A region is a geographic deployment area. Availability zones are separate locations within a region, designed to limit the impact of some infrastructure failures. Multiple zones can improve availability; multiple regions add decisions about data replication, routing, and recovery.

Understand these building blocks:

- Identity: users, workload roles, policies, temporary credentials, and audit logs.
- Networking: virtual networks, subnets, routes, firewalls, DNS, load balancers, and private service access.
- Compute: virtual machines, managed application runtimes, containers, and functions.
- Storage: block storage for disks, file storage for shared files, and object storage for objects addressed by key.
- Data: relational databases, key-value or document databases, caches, and queues.

A subnet's name does not determine whether it is public. Routes, public addressing, firewalls, and service configuration determine reachability. Draw and verify the actual request path.

## Build one small system

Use a separate learning environment with synthetic data. Deploy an application, connect it to a database, give the application a limited workload identity, and expose only the intended entry point. Add TLS, health checks, logs, backups, and infrastructure code.

Keep development and production boundaries explicit. Check account, region, and identity before making changes. Reusing an infrastructure template creates a separate deployment; it does not automatically copy the application's data.

The [Floci labs](../labs/floci/README.md) provide a local introduction to AWS-style APIs. Emulator behavior is useful for learning but does not establish production service or IAM parity.

## Cost and architecture

Track ownership with tags or labels, set budget notifications, and inspect storage, network egress, idle resources, and logging costs. Budget alerts generally report spending rather than enforcing a hard spending limit. Interruptible capacity suits workloads that tolerate termination; reservations or commitments need a predictable demand forecast.

Before migrating, inventory dependencies, data volume, capacity, access requirements, recovery targets, and ongoing operating cost. Test a migration and its fallback before switching traffic. Review applicable legal and compliance requirements with the responsible people; provider certifications alone do not make an application compliant.

References: [AWS Well-Architected](https://aws.amazon.com/architecture/well-architected/) and [Google Cloud Well-Architected Framework](https://cloud.google.com/architecture/framework).
