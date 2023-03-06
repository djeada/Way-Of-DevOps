Terraform -> Ansible -> Kubernetes -> Docker Containers

Am I missing anything? All those technologies seem to synergize with each other. Is there overlap, could this be simplified or improved?

Terraform to provision infrastructure

Ansible for configuration management of that infrastructure

Kubernetes for docker container orchestration

Ansible is (was) more common when managing VMs and bare metal servers. If you just use k8s, you just need terraform and k8s tooling.

Yep. There's rarely a need for ansible; terraform gets the nodes up, kubernetes handles what runs on the nodes.

Keeping nodes "up to date" is more time and effort consuming than simply bumping versions and replacing hosts.

What configures the nodes then?


Most commonly, terraform creates the autoscaling groups that have scripts that run to bootstrap the nodes. This is whether you use EKS/GKE/AKS, or something like KOPS.

If you have a host fall over at 2am do you really want to get a pager alert and get up to replace it? Or just let your automation tooling do that for you?


Those scripts can be replaced by ansible, or rather you can do a single ansible playbook call and it should configure them as they're brought up.

I'd rather bake the configuration into the image though, apart from environment variables.

That's not realistic though.

Nodes scale up and down all the time, without you even be aware of it. Do you expect to run playbooks everytime a node gets scaled out?

The whole point of AMI's is to bootstrap your machines.


There doesn't need to be manual intervention, the user data in the auto scale group runs the playbooks just like it runs the scripts mentioned above.


Ah I misunderstood then, yep definitely makes sense


Let me rephrase, the ansible stuff is literally like any other script and can be used in many ways. My preferred approach with AMIs is to just create that image with the help of ansible. So when you deploy it, ansible doesn't run and take time.

You can run it post deployment using standard AMIs but that takes long to bring up but doesn't require you to store all kinds of images.

Ansible is nothing but a wrapper around your existing tooling. It doesn't even need a running system.

In cloud, there is no need for Ansible but it could come in handy on-prem. Kubespray is a decent Ansible based kubernetes installer for instance

I'm a fan of using Ansible via ansible-bender to create my container images. That way I'm using a consistent definition for any role regardless of where or how I deploy it.

Terraform cannot ensure the state of your managed instances and from a security stance you want to have some sort of way of ensuring configuration management on all your instances. If you are on AWS you can use SSM State Manager to run Chef cookbooks or Ansible playbooks through the SSM agent. If you have a security team that wants to ensure compliance on your instances you should absolutely use this. If you are doing DevOps without security in mind you are up for a bad time.

I find Ansible more useful on the application side nowadays.

Regular DB move from prod to qa. Triggering some more involved data movement jobs in general.

Interestingly enough, most of the time, it just orchestrates a bunch of simple K8S jobs

That‘s intersting. I never thought of using ansible to copy databases between environments. Could you give us a quick rundown? Is there already a module available for this, or do you compile your task by just running the usual dump/load routines in ansible?

No it is not enough. Terraform does not keep track of the state of the configuration of your instances, only the state of your infrastructure. You still need some sort of configuration management to ensure that the state of your instances do not change over time, and stay in compliance or stay hardened. You may not have the DevSecOps role, but it is still everyone's responsibility to think about security within your automation or CICD pipelines.
