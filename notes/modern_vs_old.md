## Old ways

I'm talking full manual sysadmin work, SSHing into boxes, 1 VM per service, manually editing config files, making sure everything works together. No monitoring or alerting, flimsy backups. Alerting is done by others that report the system is down. Waking up to something blown up. Sleeping hoping something doesn't blow up sucks, especially those 3am calls. If everything went up in smoke today there's no way to restore it quickly without extracting the needed bits from the backups and setting everything up from scratch. No infrastructure as code, no containers, no automation. No accountability or proper environment tracking of installed packages or versions, no upgrade policy or patching policy. Pretty much YOLO deployments. But hey, it does work!

I'm the one to blame for this because I never gave myself a chance to learn all the new technologies. I would rather spend the extra time to deploy something manually and slow because without other means or knowledge, it was faster to continue like that because I knew 100% it would work. It was a bit of a control issue as well. I chose to know exactly what I was typing to get things going or repaired, rather than just turn to a bunch of tools and let them do the black magic. I had a very high responsibility to make sure things functioned, so much so I just didn't trust myself to use tools I wasn't well versed with in production. Still, managed to keep things up and running pretty well without them, but so much time was spent on doing that.

I'm in a good position now because I have time on my hands and I'm about to deploy a bunch of new services soon and I'd like to use it as a chance to upgrade my knowledge. I'd like to make this deployment safe and reliable, and all future deployments. I'd like to make it so I can deploy a dev environment and a production environment easily. I'd like to make it so every deployment is monitored, logs easily available for checking things out. And most importantly, I'd like to have a solid backup solution with an easy to restore system. I'd like to be able to do a full upgrade and rollback if needed.

But I'm not sure how to start with this. I've done a lot of research into devops tools before writing this post. And I have a lot of tools on my radar, such as Docker, Ansible, Vagrant, Terraform, Helm, Chef, Kubernetes, Longhorn, ELK, Grafana, Prometheus, Graylog, Jaeger, and all sorts else. I started by completing the tutorials on the KodeKloud platform, which I just completed the Ansible one.

I'm a fast learner, but certain things are proving tough to wrap my head around. I understand how Ansible works and what it's for, and I think it's really damn cool. But I'm struggling to apply it to my situation due to lack of knowledge and experience with how things could be done. Like, I don't even know what would be the first Playbook I would write. I feel like I am thinking so much in the past.

When it comes to Docker, I understand it's similar to a VM just not a full OS is running, only a single process. I can understand that I need to turn my deployments into Docker images for any chance at a good devops workflow, but that is proving tough too. For example one service is a PHP webapp which has a couple of cronjobs setup. The app has a frontend, an API, and connects to redis and memcache and mysql. It's also a monolith. I'm not even sure where to start with making this high availability in Kubernetes for example. Because I'd need to deploy it 3 times, if I'm right. But if I just deployed it as it is the cron jobs would be running 3 times, and they are all designed to only run 1 at a time and no duplicates. I'm not sure what the right thing is to do, and not sure where to gain the knowledge except with trial and error.

My end goal would be to use Kubernetes and understand that ecosystem. Do I start with that, just jump right in and fill in the gaps, solve problems as they come? I feel like even though tools like Ansible are cool, what's the point in writing Playbooks to configure my VMs for my deployments if I'm going to make Docker images out of them anyway? I should just write them as Dockerfiles and build the image? Or do I use Anisble to deploy the environment inside a Docker image, so the Dockerfile is provisioned using a Playbook? If I'm going to use Kubernetes, why even bother with VMs? Either way, I need images to throw them at Kubernetes and at the very least have some Playbooks to deploy Kubernetes and setup machines as nodes.

## Solution

If you dont have yet, make sure to start by hosting a git repo somewhere (eg. gitea) and an tool like jenkins to have a place to trigger your automation bit

you have looked at ansible and you plan to do away with VMs at some point, I will not look at the way to automate building VMs (you probably have some sort of golden image already). Instead make a playbook about core OS stuff like configuring SSH, users, sudoers, installing the tools you need, and generally doing the OS tuning you need. If basic tunning is different it is ok, you can have different roles. once you ran those in test VMs, and you know they work, run them in your dev, then in prod. It is very scary, but a necessary first step. Make sure to do all your fleet, so it is consistent.

Once you have consistent ssh, start with automating backups. I'd prioritise data backup, make sure they are uploaded to a cloud (maybe encrypted). I am talking databases dump, user generated files etc. Things you cannot make up with the help of a few devs.

Once you have that done you can look at backing up apps configuration. Thats config files, cron jobs, custom files etc. Bonus point if it end up in a repo so you can track change the devs made on the server .

Then you can tackle installation of middleware, like PHP version, and making more specialised roles for your different kind of servers.

You can also start to make different VM for your backend, front end, DB etc. it is a hit in terms of VMs to manage, but by now you should have automated enough to be able to manage.

Once you can get a VM from zero to ready for an app and manage to backup all the configuration for a particular service/set of services(and you manage to restore it) them you are ready to automate the app delivery.

You can start to push config change from the repo (so going from the repo is a backup to a source of truth). I guess there are ways to do that that are best practices and others, but dont feel like it has to be perfect to be useful.

The process of going from nothing to some automation will help you make the dev make the code better, but thats not instant. Making stuff stateless is hard.

Eg. figuring out how to split your monolith and get the devs to follow your lead on some fundamental changes of process will not happen overnight and splitting that change into many small changes is more palatable.

Ansible and Docker don’t really go together, but think of Docker as phase 2, you just aren’t ready yet.

BUT, you could use docker (and docker-compose) to quickly spin up a dozen light weight Linux boxes, and use Ansible to configure them all :)

I’d start by getting some monitoring in place so you know what’s down before your users do. I like Prometheus/Grafana, but you have options. After that, get to the point where you can consistently build your VMs with ansible. For services you’re deploying, it’s worth looking at packer, which is a wrapper around your hyper visor and provisioning tool (ansible) that makes building VM images easier. That gives you a way to quickly reconstitute your infra, then you need a way to do backups.

Eventually you could dockerise your apps, and use ansible to deploy the images and start the containers, but that’s not a small step to take. That’s going to take a while. By this point, you’ll probably have a better idea of what’s needed going forward.
