# Google Cloud Architect Operations, Cost and Migration Quiz

Notes: [Google Cloud architecture for the Professional Cloud Architect exam](../notes/gcp_cloud_architecture.md), [Observability and incidents](../notes/observability.md), [CI/CD](../notes/ci_cd.md), [Terraform and infrastructure as code](../notes/terraform_and_iac.md), [Cloud fundamentals](../notes/cloud.md)

Check your understanding of monitoring and logging, delivery tooling, infrastructure as code, pricing models, migration tools and the Well-Architected Framework on Google Cloud.

#### Q. A security team wants to query application and audit logs from all 150 projects in the organization with SQL from one place, including projects created later. What should you do?

* [ ] Grant the analysts Logs Viewer in every project and search each one
* [x] An organization aggregated sink, including children, to BigQuery
* [ ] Increase the retention of the `_Default` log bucket in every project
* [ ] Install the Ops Agent on every VM and point it at a central project

> **Explanation:** An aggregated sink at the organization with child projects included routes matching logs from every current and future project to one destination. Per-project access does not centralize anything, and the Ops Agent covers only VMs.

#### Q. A chatty service writes large volumes of debug logs that nobody uses, and Cloud Logging costs are rising. What should you do?

* [x] Add an exclusion filter so those debug entries are not ingested
* [ ] Lower the retention of the `_Required` log bucket to one day
* [ ] Move the service to a different region with cheaper logging
* [ ] Disable Admin Activity audit logs for the project

> **Explanation:** Exclusion filters on the Log Router drop matching entries before they are stored, which reduces ingestion cost. The `_Required` bucket's retention is fixed, and Admin Activity logs cannot be disabled.

#### Q. You need an alert when a specific error message appears in an application's logs more than 50 times in five minutes. What should you configure?

* [ ] An uptime check on the application's public endpoint
* [x] A log-based metric with an alerting policy on it
* [ ] A Cloud Trace sampling rule for the failing requests
* [ ] A log sink that copies the errors to Cloud Storage

> **Explanation:** A log-based metric counts matching log entries, and an alerting policy can fire when the count exceeds a threshold. Uptime checks test reachability, and a sink only routes logs.

#### Q. An operations team wants one set of dashboards and alerts covering metrics from 30 projects. What should you configure?

* [x] A metrics scope that includes all 30 projects
* [ ] A log sink in each project that sends metrics to BigQuery
* [ ] A shared VPC that connects all of the projects' networks
* [ ] A dashboard copied into each project with the same layout

> **Explanation:** A metrics scope lets one scoping project view and alert on metrics from many monitored projects. Shared VPC concerns networking, and copied dashboards still leave the data split across projects.

#### Q. Cloud Monitoring shows CPU metrics for Compute Engine VMs but not memory utilization or application log files. What should you do?

* [ ] Enable Data Access audit logs for Compute Engine
* [x] Install the Ops Agent on the VMs
* [ ] Turn on VPC Flow Logs for the subnet
* [ ] Create an uptime check for each VM

> **Explanation:** The Ops Agent collects guest-level metrics such as memory and disk usage and ships application logs. Hypervisor-level metrics like CPU are available without it, but in-guest data is not.

#### Q. A team must be notified when its public endpoint becomes unreachable from several locations around the world. What should you configure?

* [ ] A log-based metric on load balancer request logs
* [ ] Cloud Profiler on the backend instances
* [x] An uptime check with an alerting policy
* [ ] A budget alert on the project's billing account

> **Explanation:** Uptime checks probe an endpoint from multiple global locations, and an alerting policy notifies when checks fail. Request logs show only requests that reached the load balancer.

#### Q. A request through ten microservices is slow, and the team needs to see which service adds the latency. Which tool should they use?

* [x] Cloud Trace
* [ ] Error Reporting
* [ ] Cloud Profiler
* [ ] Log Analytics

> **Explanation:** Cloud Trace records spans across services so you can see where time is spent in one request. Cloud Profiler shows code-level CPU and memory hotspots inside a service.

#### Q. A service uses more CPU than expected in production, and developers need to find which functions consume it, with low overhead. Which tool should they use?

* [ ] Cloud Trace
* [x] Cloud Profiler
* [ ] Error Reporting
* [ ] Uptime checks

> **Explanation:** Cloud Profiler continuously samples CPU and memory usage in production code with low overhead and shows the hottest functions. Trace measures latency between operations rather than CPU use inside them.

#### Q. A team wants application exceptions grouped by cause, with a notification when a new kind of error appears. Which service provides this?

* [ ] Cloud Trace
* [ ] Log-based metrics
* [x] Error Reporting
* [ ] Cloud Profiler

> **Explanation:** Error Reporting groups similar exceptions from logs and can notify on new error groups. Log-based metrics count entries but do not group stack traces.

#### Q. A new CI pipeline needs a place to store container images for GKE and Cloud Run. Where should it push them?

* [x] Artifact Registry
* [ ] Container Registry
* [ ] A Cloud Storage bucket
* [ ] Secret Manager

> **Explanation:** Artifact Registry stores container images and language packages. Container Registry is shut down, and `gcr.io` addresses are now served by Artifact Registry.

#### Q. Builds must keep working when Docker Hub or PyPI are slow or unavailable, and the security team wants one controlled source for third-party packages. What should you set up?

* [ ] A standard Artifact Registry repository that developers upload to by hand
* [x] Artifact Registry remote repositories that cache the upstream sources
* [ ] A Cloud Storage bucket synchronized nightly with the public registries
* [ ] Cloud CDN in front of the public package registries

> **Explanation:** Remote repositories proxy and cache upstream registries, so builds read from Artifact Registry and the organization controls one access point. Manual uploads and nightly syncs are slow to maintain.

#### Q. Cloud Build jobs must download dependencies from a package server that has only an internal IP address in a VPC. What should you use?

* [ ] The default Cloud Build pool with a public IP on the server
* [x] A Cloud Build private pool connected to the VPC
* [ ] Cloud NAT on the package server's subnet
* [ ] An HA VPN tunnel from Cloud Build to the VPC

> **Explanation:** Private pools run builds on workers with access to your private network. Giving the server a public IP exposes it, and Cloud NAT only provides outbound access for resources in the VPC.

#### Q. The same release must be promoted through dev, staging and production targets on GKE and Cloud Run, with manual approval before production and easy rollback. What should you use?

* [ ] Separate Cloud Build triggers that each deploy the latest image
* [x] A Cloud Deploy pipeline with approval on the prod target
* [ ] Infrastructure Manager deployments, one for each environment
* [ ] A Cloud Run function that copies images between projects

> **Explanation:** Cloud Deploy promotes one release through ordered targets, supports approvals, canary deployments and rollback. Separate triggers can deploy different builds to each environment.

#### Q. A new Cloud Run revision should receive 5% of traffic while the previous revision serves the rest. What should you do?

* [ ] Deploy the revision to a second region and use weighted DNS
* [ ] Create a second service and split traffic with a firewall rule
* [x] Split traffic between the two revisions of the service
* [ ] Set the new revision's minimum instances to 5% of the old one

> **Explanation:** Each Cloud Run deployment creates a revision, and the service can split traffic by percentage between revisions for gradual rollouts. The other options build a canary by hand.

#### Q. A company still manages infrastructure with Cloud Deployment Manager templates. What should it do?

* [ ] Keep the templates, because Deployment Manager is the strategic tool
* [ ] Convert the templates into Cloud Build YAML files
* [x] Migrate the configurations to Terraform or Infrastructure Manager
* [ ] Replace the templates with gcloud commands typed in Cloud Shell

> **Explanation:** Deployment Manager reached end of support in March 2026, and Google points users to Terraform and Infrastructure Manager. Manual commands lose the reviewable, repeatable definitions.

#### Q. Developers want to run integration tests against Pub/Sub on their laptops without creating cloud resources or incurring cost. What should they use?

* [ ] A dedicated test project with a small quota
* [x] The Pub/Sub emulator
* [ ] Memorystore as a stand-in for Pub/Sub
* [ ] Cloud Shell with a temporary topic

> **Explanation:** Google provides local emulators for Pub/Sub, Firestore, Bigtable and Spanner for development and tests. A test project and Cloud Shell still create real resources.

#### Q. A company will expose APIs to external partners and needs quotas per partner, analytics, monetization and a developer portal. What should it use?

* [x] Apigee
* [ ] API Gateway
* [ ] Cloud Armor
* [ ] Cloud Load Balancing

> **Explanation:** Apigee is Google's full API management platform with quotas, security policies, analytics, monetization and portals. API Gateway is a lighter option for fronting serverless backends.

#### Q. A workload runs a steady baseline of N2 VMs in one region around the clock, and the company expects this for the next three years. How can it reduce compute cost the most?

* [ ] Rely on the automatic sustained use discounts alone
* [x] Buy a three-year resource-based commitment
* [ ] Move the baseline VMs to Spot VMs in the same region
* [ ] Buy a one-year resource-based commitment and renew it

> **Explanation:** A three-year resource-based committed use discount gives a larger discount than sustained use discounts for predictable usage in one region. Spot VMs can be reclaimed at any time, which a steady baseline cannot tolerate.

#### Q. A company's compute spend is predictable, but workloads move between regions, machine series, GKE and Cloud Run over time. Which commitment fits best?

* [ ] Resource-based commitments for each machine series
* [x] A spend-based flexible committed use discount
* [ ] Sole-tenant node reservations in each region
* [ ] A BigQuery Enterprise edition commitment

> **Explanation:** Spend-based flexible commitments apply to eligible Compute Engine, GKE and Cloud Run usage and are not tied to one region or machine series. Resource-based commitments cover specific resources in one region.

#### Q. Which of these workloads receives sustained use discounts automatically?

* [x] An N2 VM that runs for the whole month
* [ ] An E2 VM that runs for the whole month
* [ ] A Spot VM that runs for the whole month
* [ ] An N2 VM fully covered by a commitment

> **Explanation:** Sustained use discounts apply only to some older series such as N1, N2, N2D and C2. E2 and newer series are not eligible, and usage already covered by a commitment does not receive them.

#### Q. A research project has a fixed grant, and spending must stop automatically when a set amount is reached, even at the cost of downtime. What should you do?

* [ ] Set a budget alert that emails all of the billing administrators
* [x] Send budget alerts to Pub/Sub and trigger automation that stops resources
* [ ] Lower the project's quotas by hand once the threshold is reported
* [ ] Buy a committed use discount equal to the size of the grant

> **Explanation:** Budgets do not cap spending, but their Pub/Sub messages can trigger a function that stops resources or disables billing. Email depends on a person acting, and a commitment adds spend.

#### Q. Analysts query a large BigQuery table of events, usually filtering by event date and customer, and on-demand query costs are high. What should you do first?

* [ ] Copy the table to Cloud SQL for the analysts' queries
* [x] Partition the table by event date and cluster it by customer
* [ ] Export the table to Cloud Storage in the Archive class
* [ ] Move the dataset to a different multi-region location

> **Explanation:** On-demand pricing charges for data scanned. Partitioning and clustering let BigQuery skip data that the filters exclude, which reduces bytes processed.

#### Q. A data team wants to know how many bytes a BigQuery query would process before running it. What should it do?

* [ ] Run the query with `LIMIT 10`
* [x] Run the query with `bq query --dry_run`
* [ ] Check the table's long-term storage size
* [ ] Run the query in a smaller reservation

> **Explanation:** A dry run validates the query and returns the bytes it would process without running it. `LIMIT` does not reduce the data scanned for most queries.

#### Q. A company has a steady, heavy BigQuery workload and wants predictable capacity pricing with a one-year discount. Which option supports this?

* [x] An Enterprise edition reservation with a one-year capacity commitment
* [ ] A Standard edition reservation with a one-year capacity commitment
* [ ] On-demand pricing with a one-year bytes-scanned commitment
* [ ] An Autoclass policy on the datasets with a one-year term

> **Explanation:** Enterprise and Enterprise Plus editions offer one-year and three-year capacity commitments on top of autoscaling. Standard edition does not offer commitments, and on-demand charges per data scanned.

#### Q. An application serves users in one country from one region. The company wants to reduce network cost and accepts that traffic travels more of the path over the public internet. What should you do?

* [ ] Use a global external Application Load Balancer
* [x] Use the Standard Network Service Tier
* [ ] Add Cloud Interconnect for user traffic
* [ ] Spread the VMs across three regions

> **Explanation:** The Standard tier is cheaper than Premium and hands traffic to the internet closer to the region; it supports only regional load balancers, which this application needs. Global load balancing requires Premium.

#### Q. A team plans to move a self-managed MySQL database to Cloud SQL with small changes to the application. Which migration strategy is this?

* [ ] Rehost
* [x] Replatform
* [ ] Refactor
* [ ] Repurchase

> **Explanation:** Replatforming, or lift and optimize, makes small changes to use managed services. Rehosting moves the workload as it is, refactoring changes the application's architecture, and repurchasing replaces it with SaaS.

#### Q. Before planning a migration, a company needs an inventory of its on-premises servers, their utilization and a total cost of ownership estimate for Google Cloud. Which service should it use?

* [x] Migration Center
* [ ] Database Migration Service
* [ ] Storage Transfer Service
* [ ] Cloud Deploy

> **Explanation:** Migration Center discovers assets, collects utilization data and produces TCO and sizing reports for migration planning. The other services move data or deploy applications.

#### Q. A company must move 300 VMs from vSphere to Compute Engine, test each one in Google Cloud before cutover, and keep downtime minimal. Which tool fits?

* [ ] Storage Transfer Service with agents
* [ ] Transfer Appliance
* [x] Migrate to Virtual Machines
* [ ] Database Migration Service

> **Explanation:** Migrate to Virtual Machines replicates VMs continuously from vSphere, AWS or Azure, supports test clones and performs cutover with short downtime. Transfer tools copy files and objects, not running VMs.

#### Q. A company wants to move hundreds of VMware VMs to Google Cloud quickly while keeping its vSphere tools and operating processes. What should you recommend?

* [x] Google Cloud VMware Engine
* [ ] GKE Autopilot clusters
* [ ] Cloud Run services
* [ ] Sole-tenant nodes with a custom hypervisor

> **Explanation:** Google Cloud VMware Engine runs a VMware environment in Google Cloud, so VMs move without re-platforming and teams keep their tooling. The other options require converting the workloads.

#### Q. An on-premises Oracle database must move to AlloyDB for PostgreSQL with continuous replication and a short cutover window. Which service should you use?

* [ ] Storage Transfer Service
* [x] Database Migration Service
* [ ] Transfer Appliance
* [ ] Migrate to Virtual Machines

> **Explanation:** Database Migration Service supports heterogeneous migrations from Oracle to AlloyDB or Cloud SQL for PostgreSQL, with schema conversion and change data capture for low downtime. The other tools move files or VMs.

#### Q. 200 TB of objects in Amazon S3 must be copied to Cloud Storage, followed by daily incremental synchronization until cutover. What should you use?

* [x] Storage Transfer Service
* [ ] Transfer Appliance
* [ ] Database Migration Service
* [ ] Datastream

> **Explanation:** Storage Transfer Service copies from S3 and other sources into Cloud Storage on a schedule, transferring only changed objects. Transfer Appliance is for offline transfer from your own data center.

#### Q. A company must move 1 PB from its data center within a few weeks, but its internet link is only 100 Mbps. What should it use?

* [ ] Storage Transfer Service over the existing link
* [x] Transfer Appliance
* [ ] Cloud Storage FUSE mounted on the servers
* [ ] `gcloud storage cp` run in parallel

> **Explanation:** At 100 Mbps, 1 PB would take years online. Transfer Appliance is shipped to the data center, filled locally and returned to Google, which avoids the network bottleneck.

#### Q. About how long does it take to transfer 10 TB over a dedicated 1 Gbps link running at full utilization?

* [ ] About one hour
* [x] About one day
* [ ] About ten days
* [ ] About one month

> **Explanation:** 10 TB is 80,000 gigabits, and at 1 gigabit per second that is about 80,000 seconds, or roughly 22 hours. Real links rarely sustain full utilization, so plan for longer.

#### Q. An architecture review recommends choosing regions with lower carbon intensity and measuring the carbon footprint of workloads. Which Well-Architected Framework pillar does this belong to?

* [ ] Reliability
* [ ] Operational excellence
* [x] Sustainability
* [ ] Performance optimization

> **Explanation:** The sustainability pillar covers low-carbon regions, efficient resource use and measuring carbon footprint. The framework's other pillars are operational excellence, security, reliability, cost optimization and performance optimization.

#### Q. Two options in a case-study question both satisfy every stated requirement. One uses a managed service; the other adds self-managed VMs and custom scripts. Which should you usually choose?

* [ ] The self-managed design, because it gives the team more control
* [x] The managed design, because it meets the needs with less to operate
* [ ] Whichever design uses the largest number of Google Cloud services
* [ ] Whichever design would be cheapest if the requirements were ignored

> **Explanation:** Google's recommended practice, and the exam's expected answer, is the simplest managed service that meets the requirements and constraints. Extra components add operational overhead without serving a stated need.
