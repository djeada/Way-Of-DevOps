Are you into any sports? Video games? Books? Create a simple website in whatever language to display stats and info from something your interested in.

* Use a database to store the data
* Use Redis to cache the data from your database to reduce load
* Setup a local dev environment using docker compose

And now the ops part (this is AWS focused, but just translate it to whatever cloud you prefer)

* Deploy your app, database, and cache to ec2 instances
* Provision the instances with Terraform
* Configure the instances with Ansible
* Setup a domain name to serve your app
* Move the domain to route53 by updating NS records
* Add Tls wildcard cert to the domain using ACM or certbot
* Implement tests, linting, and formatting automatically using CI pipelines
*  Make updates automatically deploy issuing CD pipelines
* Change the infrastructure to k8s and update all the pipelines
* Connect the VPCs to your home network using a VPN gateway
