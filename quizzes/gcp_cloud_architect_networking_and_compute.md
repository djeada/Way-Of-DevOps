# Google Cloud Architect Networking and Compute Quiz

Notes: [Google Cloud architecture for the Professional Cloud Architect exam](../notes/gcp_cloud_architecture.md), [Networking and HTTP](../notes/networking.md), [Containers and orchestration](../notes/containers_and_orchestration.md)

Check your understanding of VPC design, firewalls, private access, hybrid connectivity, load balancing and choosing compute services on Google Cloud.

#### Q. VMs in `us-central1` and `europe-west1` are in the same VPC network and must talk to each other over internal IP addresses. What do you need to configure?

* [x] Only firewall rules that allow it; the VPC already spans regions
* [ ] An HA VPN tunnel between the two regional subnets
* [ ] VPC Network Peering between the two regional subnets
* [ ] A Cloud NAT gateway in each of the two regions of the VPC

> **Explanation:** A VPC network is global and its subnets are regional, so subnet routes already connect regions over Google's network. Ingress is denied by default, so firewall rules must allow the traffic.

#### Q. A new VPC will later connect to an on-premises network that already uses parts of `10.128.0.0/9`. Which network design should you choose?

* [ ] An auto mode VPC, converted to custom mode after the connection is built
* [x] A custom mode VPC with subnet ranges planned not to overlap on-premises
* [ ] The default network with extra static routes for the on-premises ranges
* [ ] One auto mode VPC per region so that ranges can be chosen per region

> **Explanation:** Auto mode creates a subnet in every region from `10.128.0.0/9`, which would overlap here. Custom mode lets you plan non-overlapping ranges, which hybrid routing requires.

#### Q. You create a custom mode VPC and add no firewall rules or policies. Which traffic is allowed?

* [ ] All traffic between VMs in the same subnet, but no egress
* [x] Egress from VMs; unsolicited ingress is denied
* [ ] Ingress for SSH and RDP from any source address
* [ ] No traffic in either direction until rules exist

> **Explanation:** Every VPC has implied rules at the lowest priority that allow all egress and deny all ingress. The default network adds extra allow rules, but a custom VPC you create has only the implied ones.

#### Q. Developers can edit network tags on their VMs. Security needs firewall rules for database access that developers cannot bypass by changing tags. What should you do?

* [ ] Give the rules a higher priority number than other rules
* [ ] Target the rules by instance name instead of tag
* [x] Target the rules by service account instead of network tag
* [ ] Replace the allow rules with egress deny rules

> **Explanation:** Changing a VM's service account requires IAM permissions on that service account, while network tags can be changed by anyone who can edit the instance. A higher priority number means lower priority.

#### Q. SSH from the internet must be blocked in every project of the organization, and project administrators must not be able to override this. What should you do?

* [x] A hierarchical firewall policy on the organization that denies it
* [ ] Create a priority 0 deny rule in each project's VPC firewall rules
* [ ] Set an organization policy that disables SSH keys in instance metadata
* [ ] Add a deny rule to each project's own global network firewall policy

> **Explanation:** Hierarchical firewall policies are evaluated before project-level rules and policies, and project administrators cannot modify them. Rules created inside each project can be changed or deleted by that project's administrators.

#### Q. Compliance requires signature-based intrusion detection and prevention for traffic between workloads in a VPC. Which service provides this?

* [ ] Cloud Armor Enterprise with Adaptive Protection
* [x] Cloud NGFW Enterprise with firewall endpoints
* [ ] VPC firewall rules targeted by service account
* [ ] VPC Service Controls with ingress and egress rules

> **Explanation:** The Enterprise tier of Cloud Next Generation Firewall adds intrusion detection and prevention through Google-managed firewall endpoints. Cloud Armor protects services behind load balancers, and VPC Service Controls governs Google API access.

#### Q. A central network team must control subnets, routes and firewalls, while 20 application teams in the same organization keep their own projects for billing and IAM. What should you do?

* [x] Shared VPC, with a host project for the network team and service projects
* [ ] Connect the 20 projects' VPCs in a full mesh of VPC Network Peering connections
* [ ] Give each project its own VPC and connect them with HA VPN tunnels to a hub
* [ ] Move all teams into one project and separate them with IAM conditions

> **Explanation:** Shared VPC centralizes network administration in a host project while service projects keep their own resources, IAM and billing. Peering leaves each VPC administered separately, and one project removes the team boundaries.

#### Q. VPC A is peered with VPC B, and VPC B is peered with VPC C. A VM in A cannot reach a VM in C. Why?

* [x] VPC Network Peering is not transitive
* [ ] Peered networks must be in the same region
* [ ] Firewall rules in B drop forwarded packets by default
* [ ] Peering supports only external IP addresses

> **Explanation:** A peering connection exchanges routes only between its two networks, so A never learns C's routes through B. Use a direct peering, Network Connectivity Center or a hub design for transitive connectivity.

#### Q. Dozens of VPC networks and several on-premises sites need any-to-any connectivity that is managed in one place. Which service fits best?

* [ ] A full mesh of VPC Network Peering connections
* [x] Network Connectivity Center with VPC and hybrid spokes
* [ ] Cloud NAT gateways configured in each VPC network
* [ ] Private Google Access enabled on every subnet

> **Explanation:** Network Connectivity Center provides hub-and-spoke connectivity across many VPCs and hybrid connections. A peering mesh grows quadratically and is not transitive, and Cloud NAT and Private Google Access do not connect networks.

#### Q. VMs without external IP addresses must call the Cloud Storage and BigQuery APIs, and must have no path to the general internet. What should you do?

* [x] Enable Private Google Access on the VMs' subnet
* [ ] Configure Cloud NAT for the VMs' subnet
* [ ] Peer the VPC with the Cloud Storage service network
* [ ] Add external IPs and restrict them with firewall rules

> **Explanation:** Private Google Access lets internal-only VMs reach Google APIs without internet access. Cloud NAT would also give them a route to any internet destination, which the requirement forbids.

#### Q. A SaaS provider in another organization publishes a service. Your VPC's IP ranges overlap with the provider's, and you need private access to the service. What should you do?

* [ ] Connect the two VPC networks with VPC Network Peering
* [ ] Attach your project to the provider's Shared VPC host project
* [x] Create a Private Service Connect endpoint for the provider's service
* [ ] Build an HA VPN tunnel between your VPC and the provider's VPC

> **Explanation:** Private Service Connect gives the service an internal IP address in your VPC and translates traffic at the endpoint, so overlapping ranges and different organizations are not a problem. Peering and VPN require non-overlapping routes, and Shared VPC works within one organization.

#### Q. GKE nodes without external IP addresses must download packages from public internet repositories, and no inbound connections from the internet may reach them. What should you do?

* [x] Configure Cloud NAT on a Cloud Router in the nodes' region
* [ ] Enable Private Google Access on the nodes' subnet
* [ ] Place an internal passthrough Network Load Balancer in front of the nodes
* [ ] Create a Private Service Connect endpoint that targets the internet

> **Explanation:** Cloud NAT provides managed outbound internet access for private resources and does not accept unsolicited inbound connections. Private Google Access reaches only Google APIs and services.

#### Q. A company needs encrypted connectivity from its data center to Google Cloud within days, with moderate bandwidth and a 99.99% availability SLA. What should you choose?

* [x] HA VPN with BGP sessions through Cloud Router
* [ ] Classic VPN with static routes to the data center
* [ ] Dedicated Interconnect at a colocation facility
* [ ] Direct Peering with Google at an exchange point

> **Explanation:** HA VPN is quick to set up, encrypted with IPsec, and offers a 99.99% SLA in supported topologies. Classic VPN offers 99.9%, Interconnect takes longer to provision and is not encrypted by default, and Direct Peering reaches public Google services.

#### Q. A company's data center is far from any colocation facility where Google is present. It needs a private, SLA-backed connection of a few gigabits per second. What should you choose?

* [ ] Dedicated Interconnect from the data center
* [x] Partner Interconnect through a supported provider
* [ ] Carrier Peering through an internet provider
* [ ] Cross-Cloud Interconnect to Google Cloud

> **Explanation:** Partner Interconnect reaches Google through a service provider when you cannot reach a colocation facility or need less than a full circuit. Carrier Peering reaches public Google services, and Cross-Cloud Interconnect links Google Cloud to another cloud provider.

#### Q. Which Dedicated Interconnect topology does Google document for a 99.99% availability SLA?

* [x] Four connections, two in each of two metropolitan areas, serving two regions
* [ ] Two connections in one metropolitan area on different edge availability domains
* [ ] One connection per region with a Classic VPN tunnel as the backup path
* [ ] Two connections in the same edge availability domain of one metropolitan area

> **Explanation:** The 99.99% topology spreads four connections across two metros and two regions, so a metro failure leaves capacity. Two connections in one metro on different edge availability domains is the 99.9% topology.

#### Q. Compliance requires that traffic over a Dedicated Interconnect be encrypted in transit. What should you do?

* [ ] Nothing, because Interconnect traffic is encrypted by default
* [x] Use MACsec on supported circuits or HA VPN over Cloud Interconnect
* [ ] Route the Interconnect traffic through a Cloud NAT gateway
* [ ] Enable Private Google Access on the VLAN attachments

> **Explanation:** Interconnect traffic is private but not encrypted by default. MACsec encrypts at the link layer, and HA VPN over Cloud Interconnect adds IPsec tunnels over the VLAN attachments.

#### Q. An analytics platform in Google Cloud needs a private, high-bandwidth link to workloads in AWS without routing through an on-premises data center. What should you use?

* [ ] Partner Interconnect to an on-premises colocation cage
* [ ] VPC Network Peering between the two providers
* [x] Cross-Cloud Interconnect to the other provider
* [ ] Private Google Access on the analytics subnet

> **Explanation:** Cross-Cloud Interconnect provides dedicated physical connections between Google Cloud and other cloud providers. VPC Network Peering connects only Google Cloud VPC networks.

#### Q. VMs in Google Cloud must resolve names in the on-premises zone `corp.example.com`, served by on-premises DNS servers reachable over HA VPN. What should you configure?

* [x] A Cloud DNS forwarding zone that targets the on-premises servers
* [ ] An inbound DNS server policy on the VPC network that hosts the VMs
* [ ] A public Cloud DNS zone named `corp.example.com` with copied records
* [ ] Startup scripts that add on-premises hosts to each VM's `/etc/hosts`

> **Explanation:** A forwarding zone sends queries for that domain to the on-premises resolvers. An inbound server policy serves the opposite direction, letting on-premises clients resolve Google Cloud private zones.

#### Q. A global retail site needs one anycast IP address, backends in three regions, caching of product images at the edge, and protection against OWASP Top 10 attacks. What should you deploy?

* [ ] An external passthrough Network Load Balancer in each region with DNS round robin
* [x] A global external Application Load Balancer with Cloud CDN and Cloud Armor
* [ ] A regional internal Application Load Balancer with a Cloud Armor policy
* [ ] A global external proxy Network Load Balancer with Cloud CDN enabled

> **Explanation:** The global external Application Load Balancer gives one anycast IP with multi-region backends and supports both Cloud CDN and Cloud Armor WAF rules. Cloud CDN is not available on proxy Network Load Balancers.

#### Q. A UDP game server must receive the original client IP address on each packet. Which load balancer should you use?

* [ ] Global external Application Load Balancer
* [ ] Global external proxy Network Load Balancer
* [x] External passthrough Network Load Balancer
* [ ] Regional internal Application Load Balancer

> **Explanation:** Passthrough load balancers forward packets without terminating connections, so backends see the client source IP, and they support UDP. Proxy load balancers open a new connection to the backend.

#### Q. Internal microservices in one region communicate over HTTP and need path-based routing. They must not be reachable from the internet. Which load balancer fits?

* [x] Regional internal Application Load Balancer
* [ ] Global external Application Load Balancer
* [ ] Internal passthrough Network Load Balancer
* [ ] Regional external proxy Network Load Balancer

> **Explanation:** Path-based routing is a layer 7 feature of Application Load Balancers, and the internal regional variant is reachable only from inside the VPC and connected networks. A passthrough load balancer works at layer 4.

#### Q. A regulation requires that TLS for a public web application be terminated only inside one EU region. Which load balancer should you use?

* [ ] Global external Application Load Balancer with EU backends
* [x] Regional external Application Load Balancer in an EU region
* [ ] Global external proxy Network Load Balancer with EU backends
* [ ] External passthrough Network Load Balancer with Cloud CDN

> **Explanation:** A regional external Application Load Balancer runs its proxies in the chosen region. Global load balancers terminate connections at Google edge locations worldwide, even when the backends are in the EU.

#### Q. A public application behind a global external Application Load Balancer receives SQL injection attempts and floods of requests from a few clients. What should you do?

* [x] Attach a Cloud Armor policy with preconfigured WAF rules and rate limiting
* [ ] Add VPC firewall rules that deny port 443 from unknown source ranges
* [ ] Enable Cloud CDN so that the edge caches absorb the malicious requests
* [ ] Move the backends to private subnets and give them Cloud NAT gateways

> **Explanation:** Cloud Armor policies attach to the load balancer's backend services and filter requests at Google's edge with OWASP-based rules and per-client rate limits. VPC firewall rules see traffic from the load balancer, not from the attackers.

#### Q. A legacy application needs a custom kernel module and licensed software tied to the operating system, and it must be moved to Google Cloud with minimal changes. Which compute service fits?

* [ ] Cloud Run
* [x] Compute Engine
* [ ] GKE Autopilot
* [ ] Cloud Run functions

> **Explanation:** Compute Engine gives full control of the operating system and kernel, which lift-and-shift workloads with OS-level dependencies require. Serverless platforms and Autopilot do not allow kernel changes.

#### Q. A stateless, containerized HTTP API has spiky daytime traffic and is idle at night. The team wants the least operational overhead and no cost while idle. What should you use?

* [x] A Cloud Run service
* [ ] A GKE Standard cluster with the cluster autoscaler
* [ ] A regional managed instance group with autoscaling
* [ ] An App Engine flexible environment application

> **Explanation:** Cloud Run runs containers without cluster management and scales to zero when there are no requests. GKE Standard and MIGs keep nodes or VMs running, and App Engine flexible does not scale to zero.

#### Q. A containerized task processes one day's files, then exits. It runs every night and can split its work into parallel tasks. Which service fits with the least management?

* [ ] A Cloud Run service with minimum instances set to one
* [x] A Cloud Run job executed on a schedule
* [ ] A Compute Engine VM that runs the task from cron
* [ ] A GKE Standard cluster running the task as a DaemonSet

> **Explanation:** Cloud Run jobs run containers to completion, with parallel tasks, and suit scheduled batch work. A service is built to answer requests, and a VM or cluster adds infrastructure that sits idle most of the day.

#### Q. Each image uploaded to a Cloud Storage bucket must trigger a small piece of code that creates a thumbnail. The team wants the least code and infrastructure. What should you use?

* [x] A Cloud Run function triggered by the object finalize event
* [ ] A Compute Engine VM that lists the bucket every minute
* [ ] A GKE CronJob that compares the bucket with a database
* [ ] A Dataflow streaming pipeline that reads the bucket

> **Explanation:** Cloud Run functions deploy a single function that receives events through Eventarc, such as a new object in Cloud Storage. Polling designs add infrastructure and delay.

#### Q. Which Cloud Run resource is designed for continuously running workloads that do not serve requests, such as a pull-based queue consumer?

* [ ] Cloud Run jobs
* [x] Cloud Run worker pools
* [ ] Cloud Run functions
* [ ] Cloud Run services

> **Explanation:** Worker pools run long-lived background workers without an HTTP endpoint. Services are request-driven, jobs run to completion, and functions respond to individual events or requests.

#### Q. A team is starting a new web application and considering App Engine. What does Google currently recommend for new web applications?

* [ ] App Engine standard environment
* [ ] App Engine flexible environment
* [x] Cloud Run
* [ ] Compute Engine with a startup script

> **Explanation:** Google describes Cloud Run as the newer alternative and recommends it for developing and hosting new web applications. App Engine remains supported for existing applications.

#### Q. A team wants Kubernetes for its services but does not want to manage nodes, and prefers to pay for the resources its Pods request. Which option fits?

* [x] GKE Autopilot
* [ ] GKE Standard with node auto-provisioning
* [ ] Self-managed Kubernetes on Compute Engine
* [ ] Google Cloud VMware Engine

> **Explanation:** In Autopilot, Google manages nodes and bills for the CPU, memory and storage that Pods request. Standard clusters, even with auto-provisioning, bill for nodes and leave node management to you.

#### Q. A production GKE cluster's control plane and nodes must keep working if one zone fails. What should you create?

* [ ] A zonal cluster with a node pool in each zone
* [x] A regional cluster
* [ ] A zonal cluster with a larger node pool
* [ ] Two zonal clusters in the same zone

> **Explanation:** A regional cluster replicates the control plane and nodes across zones in a region. A zonal cluster has a single-zone control plane, even if its nodes span several zones.

#### Q. VMs in a managed instance group sometimes hang: the VM keeps running but the application stops responding. You want them replaced automatically. What should you configure?

* [x] Autohealing with an application health check
* [ ] Autoscaling on CPU utilization
* [ ] A larger machine type in the template
* [ ] A snapshot schedule for the boot disks

> **Explanation:** Autohealing recreates instances that fail an application-level health check. The VM's running state does not show that the application has hung, and autoscaling responds to load, not to failures.

#### Q. A fault-tolerant rendering job runs for hours, can restart work from checkpoints, and must be as cheap as possible. Which capacity should you use?

* [x] Spot VMs in a managed instance group
* [ ] Sole-tenant nodes with committed use discounts
* [ ] Standard VMs with a larger machine type
* [ ] Memory-optimized VMs reserved for a year

> **Explanation:** Spot VMs use spare capacity at a large discount and can be reclaimed at any time, which suits restartable batch work. A MIG recreates them when capacity returns.

#### Q. A database's licence terms require it to run on dedicated physical cores that are not shared with other customers. What should you use?

* [ ] Confidential VMs
* [ ] Shielded VMs
* [x] Sole-tenant nodes
* [ ] Spot VMs

> **Explanation:** Sole-tenant nodes dedicate physical servers to your project, which isolation requirements and some bring-your-own-licence terms require. Confidential and Shielded VMs protect memory and boot integrity on shared hosts.

#### Q. An application needs 6 vCPUs and 40 GB of memory, and the nearest predefined machine types waste a large amount of either CPU or memory. What should you do?

* [ ] Choose the next larger predefined type
* [x] Use a custom machine type
* [ ] Run two smaller VMs per instance
* [ ] Use a memory-optimized machine family

> **Explanation:** Custom machine types let you set vCPU and memory independently within the series' limits, so you pay only for what the application needs. Larger predefined or memory-optimized shapes leave resources idle.
