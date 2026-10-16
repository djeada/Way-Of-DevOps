# Managing servers in a small company

A small fleet can still become hard to maintain when configuration lives only on individual servers. Start by making one repeated task predictable and reviewed, then expand the approach as it proves useful.

## Inventory before changing things

Record each server's purpose, owner, operating system, services, dependencies, access method, scheduled jobs, and data locations. Identify which services must recover first and what would be lost if a machine disappeared.

Back up important data and confirm a restore before making broad configuration changes. Put non-secret configuration and operational instructions in version control. Store credentials separately with access limited to the people and automation that need them.

## Start with one Ansible playbook

Choose a low-risk task on a test machine, such as managing a banner file or installing a utility. Use an inventory to select the target explicitly. Prefer modules that describe the desired state over shell commands that run unconditionally.

Review the proposed change, apply it to one machine, and run it again. An idempotent task should converge without reporting a new change on every run. Check mode and diff mode help review changes, but support depends on the module and neither proves the application will work. Diffs may also expose secrets.

Move on to service configuration only after you can validate a configuration before reloading it. Restart or reload a service through a handler when its configuration changes. Roll out to a small batch, verify health, and stop on failure before extending to the fleet.

## Organize for the next maintainer

Keep related tasks together, make environment differences explicit, and document the command that applies each change. Add roles when repeated patterns justify them. A small, readable repository is easier to maintain than a large framework created before the requirements are understood.

Track emergency manual changes and reconcile them into automation. Maintain a recovery access method while changing SSH, firewall, or administrator settings so a failed rollout does not lock everyone out.

## Review the hosting model separately

VMs can isolate services and make rebuilding easier. Containers can standardize application packaging. Managed services can remove some maintenance tasks. Evaluate each against downtime, data handling, cost, skills, and ongoing support.

Move one service at a time when separation solves a concrete problem. A small company does not need to adopt Kubernetes or move every workload to the cloud to gain repeatability, monitoring, and tested backups.

Reference: [Ansible check and diff modes](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_checkmode.html). Related: [choosing infrastructure tools](intro_to_tools.md), [modernizing an existing service](modern_vs_old.md), and [backup and recovery](backup_and_recovery.md).
