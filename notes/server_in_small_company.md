We have around 15 servers (pets not cattle), on this servers there are multiple services running (web servers, mail server, NFS, cronjobs, ...).

I'm looking for a simple way to manage all configuration files on the servers. Currently we don't have any automation tools and I'm a bit reluctant to introduce these tools since I'm the only sysadmin and I don't want to complicate the infrastructure more that it's needed.

My idea is a git repo for the config files and a bash script to copy configs from/to the servers, but if it would be easier I would consider using something like Ansible. Any suggestions on how to approach this?

## Ansible

I spent a lot of time shying away from Ansible in favor of bash scripts too and it was a mistake. Once you realize there is an Ansible module to do almost anything and that your initial folder structure can be adjusted later, it's no longer daunting.

Start with a single playbook that copies one single file to a remote IP and grow from there. You'll thank yourself later that you didn't have to write all the nice built in error and duplicate checking to make your bash scripts idempotent.

## Put into VMs

I'll preface this by saying I'm making an assumption that you're not already using VMs or containers and are just running on bare metal. 
If that's the case, then honestly where I would start is using VMs and separating out those services to separate servers. 
I would just move one service at a time, but using configuration management / IAC to build each new server. 
You don't need pipelines and ci/cd, yet, although those are quite nice to have. So go with something like VMWare or Proxmox, create separate VMs for each service, use Ansible to configure the VMs.

## Cloud

I’d also be considering the option of simplifying the setup and moving into cloud based services. This is just a hunch, but from experience I'd be willing to bet that whatever they got going on could be streamlined into a much more efficient setup and probably half the amount of servers.

