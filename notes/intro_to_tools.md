# Choosing infrastructure tools

Tools often overlap, but they solve different parts of a system's lifecycle. Decide what owns a resource or setting before deciding which products to combine.

## Match the tool to the work

| Responsibility | Typical tools | Example |
| --- | --- | --- |
| Provision infrastructure | Terraform, CloudFormation | Create a network, VM, or managed database |
| Build a machine image | Packer, with scripts or Ansible | Prepare a patched base image for new VMs |
| Configure an operating system | Ansible, Puppet, Chef, Salt | Manage packages, users, and service configuration |
| Build and run containers | Docker, Podman | Package an application and run its image |
| Orchestrate containers | Kubernetes, a managed container service | Schedule workloads, restart them, and roll out updates |
| Coordinate delivery | GitHub Actions, Jenkins, GitLab CI | Test changes, publish artifacts, and start deployments |
| Reconcile desired state | Argo CD, Flux | Keep a cluster aligned with versioned configuration |

CloudFormation provisions AWS resources; it is distinct from pipeline orchestration such as CodePipeline. A Kubernetes runtime runs container images; it does not require Docker Engine specifically.

## Common combinations

For a VM-based application, Terraform may provision the VM and Ansible may configure its operating system and services. Ansible can run during image creation, at first boot, or later as part of configuration management. Decide how updates will reach existing machines.

For replaceable VMs, Packer can build an image and Terraform can deploy a new group of instances from it. Bootstrap steps supply the small amount of configuration that depends on the environment. Replacing a host can be simpler than repairing its history of manual changes, provided data is stored and recovered separately.

For a container platform, Terraform may create the cluster while Kubernetes manifests describe workloads. Managed node images or image-building tools handle the nodes. Ansible can still be useful for surrounding machines or specialized configuration; Kubernetes does not maintain every aspect of the node operating system for you.

## Avoid conflicting ownership

Do not let two controllers continually overwrite the same setting. For example, if Terraform fixes an instance count while an autoscaler changes it, define how ownership is divided and which differences are expected.

Keep application configuration, infrastructure configuration, and secrets distinguishable even when they share a repository. Document where a change belongs and how it is reviewed and applied.

## Choose a small starting point

A single VM with a managed service and a repeatable deployment may meet a small team's needs. Compose can help reproduce a few services locally. Kubernetes becomes useful when scheduling, scaling, isolation, and rollout requirements justify operating the platform.

Compare the cost of running and learning a tool with the manual work it removes. Prefer a setup another team member can diagnose and rebuild. See [small-company servers](server_in_small_company.md) for a gradual starting point.
