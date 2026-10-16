# Way of DevOps

Notes and hands-on exercises for learning how to build, deliver, and operate software. Start with one small application and improve it step by step. The goal is to understand the work behind the tools: repeatable changes, useful feedback, secure access, and recovery when something fails.

## Learning path

1. Learn the foundations: Git, [Linux and scripting](notes/linux_and_scripting.md), [networking and HTTP](notes/networking.md), and [virtual machines](notes/virtualbox.md).
2. Follow an application from a developer's machine to a running service in [How a full-stack application reaches the cloud](notes/full_stack_app_with_cloud.md).
3. Automate delivery with [CI/CD](notes/ci_cd.md), [continuous integration](notes/continuous_integration.md), and [GitHub Actions](notes/github_actions.md).
4. Make environments reproducible with [cloud fundamentals](notes/cloud.md), [infrastructure as code](notes/terraform_and_iac.md), and [containers and orchestration](notes/containers_and_orchestration.md). Learn [which tool owns which task](notes/intro_to_tools.md) before adding more tools.
5. Operate the service using [observability](notes/observability.md), [security and secrets](notes/security_and_secrets.md), [database operations](notes/best_practices.md), and [backup and recovery](notes/backup_and_recovery.md).
6. Explore [canary releases](notes/canary_release.md), [GitOps](notes/git_ops.md), and [MLOps](notes/mlops.md) when the application needs them.

The [notes index](notes/README.md) lists every topic, including practical guidance for small teams and existing infrastructure. You can follow the path in order or use it to fill a specific gap.

## Practice

- [Hands-on lab courses](labs/README.md): 10 Floci cloud labs and 10 Wireshark + Node.js networking labs. Follow each course's setup and isolation instructions.
- [Apache example](servers/apache/README.md): serve a small website and inspect the server configuration.
- [Project ideas](project_ideas.md): build a small application, then add delivery and operational capabilities.

For each exercise, record how to start it, how to verify it works, what happens when a dependency fails, and how to clean it up. A working restore or a clear failure diagnosis is as useful as a successful deployment.

## Scope and tool choices

DevOps combines collaboration, software delivery, and operations. Teams share responsibility for changes throughout the application's life. Kubernetes, a cloud provider, or a particular pipeline product is a possible implementation choice.

A useful starting stack is Git, a Linux environment, one scripting language, a CI runner, and a deployment target. Add a container runtime, configuration management, or an orchestrator when it solves a concrete problem. Track ownership and work in a shared issue tracker such as GitHub Issues or Jira, and include operational improvements alongside feature work.

These notes explain concepts and give small examples. They are not a complete production reference architecture. Service behavior and tool versions change; use the linked documentation when implementing a real system.

## Further reading

- [Pro Git](https://git-scm.com/book/en/v2) for version control.
- [Google's SRE books](https://sre.google/books/) for reliability, monitoring, and incident response.
- [AWS Well-Architected](https://aws.amazon.com/architecture/well-architected/) and [Google Cloud Well-Architected Framework](https://cloud.google.com/architecture/framework) for architecture reviews.
- [OpenGitOps](https://opengitops.dev/) for the principles behind GitOps.
- [90 Days of DevOps](https://github.com/MichaelCade/90DaysOfDevOps) and [DevOps exercises](https://github.com/bregman-arie/devops-exercises) for additional practice.
- [The Cloud Resume Challenge](https://forrestbrazeal.com/2020/04/23/the-cloud-resume-challenge/) for an application-sized learning project.

Choose books for the problem you are working on and check their examples against the relevant tool version:

- Delivery and teamwork: The Phoenix Project, The DevOps Handbook, and Effective DevOps.
- Linux and Git: UNIX and Linux System Administration Handbook, How Linux Works, and Version Control with Git.
- Infrastructure: Terraform: Up & Running, Terraform in Action, and Ansible for DevOps.
- Containers: Docker: Up & Running, Docker in Practice, Learn Docker in a Month of Lunches, Kubernetes: Up and Running, and Cloud Native DevOps with Kubernetes.
