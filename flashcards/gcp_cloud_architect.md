# Google Cloud Professional Cloud Architect Flashcards

Review cards for the [Google Cloud architecture note](../notes/gcp_cloud_architecture.md). Each card covers a definition, a comparison, or a "when would you choose X over Y" decision that comes up in the Professional Cloud Architect exam.

## The exam

<details>
<summary>What are the six sections of the Professional Cloud Architect exam guide, and which carries the most weight?</summary>

Designing and planning a cloud solution architecture (about 25%, the largest), managing and provisioning a solution infrastructure, designing for security and compliance, analyzing and optimizing technical and business processes, managing implementation, and ensuring solution and operations excellence. Some questions refer to fictional case studies; the v6.1 guide lists Altostrat Media, Cymbal Retail, EHR Healthcare and KnightMotives Automotive.

</details>

## Resource hierarchy

<details>
<summary>What are the levels of the Google Cloud resource hierarchy?</summary>

Organization (tied to a Cloud Identity or Workspace domain), optional nested folders, projects, and resources. Every resource belongs to exactly one project. Policies set on a node are inherited by everything below it.

</details>

<details>
<summary>Why can't a project administrator remove a role that was granted on the parent folder?</summary>

IAM allow policies are additive: effective access is the union of bindings on the resource and all its ancestors. A lower level cannot subtract an inherited grant. Use a deny policy, narrow the folder grant, or move the project.

</details>

<details>
<summary>How does an organization policy differ from IAM?</summary>

IAM decides *who* may perform an action on a resource. An organization policy decides *what configurations* are allowed below a node, for every principal, using constraints such as resource locations, domain restricted sharing, or disabling service account key creation. Both are inherited, and organization policies can be tested in dry-run mode.

</details>

<details>
<summary>Which organization policy constraints commonly appear in architecture designs?</summary>

- `gcp.resourceLocations` to restrict where resources are created.
- `iam.allowedPolicyMemberDomains` (domain restricted sharing) to limit IAM grants to approved identities.
- Disabling service account key creation.
- Restricting external IPs on VMs, requiring OS Login, and skipping the default network.

</details>

<details>
<summary>What is the difference between labels, tags and network tags?</summary>

Labels are key-value metadata used for cost attribution and filtering; they appear in billing export but do not control access. Resource Manager tags are organization or project-level resources bound to resources, inherited, and usable in IAM conditions, organization policy conditions and firewall policies. Network tags are an older VM attribute used only by VPC firewall rules and routes.

</details>

<details>
<summary>How do projects and Cloud Billing accounts relate?</summary>

A billing account pays for many projects, but each project links to at most one billing account. Billing Account Administrator manages the account, Billing Account User allows linking projects to it, and Project Billing Manager allows changing a project's link.

</details>

## IAM

<details>
<summary>What are the three types of IAM roles, and when do you use each?</summary>

- **Basic** (Owner, Editor, Viewer): very broad; avoid in production.
- **Predefined**: maintained by Google per service; the default choice, picking the narrowest that works.
- **Custom**: your own permission list at organization or project level, when no predefined role is narrow enough; you maintain it.

</details>

<details>
<summary>What are IAM Conditions used for?</summary>

They restrict a role binding by attributes such as request time, resource name prefix, resource type or tags. Typical uses are access that expires automatically and access limited to resources carrying a specific tag.

</details>

<details>
<summary>How do IAM deny policies and principal access boundary policies differ from allow policies?</summary>

Only allow policies grant access. Deny policies attach to resources and block listed permissions regardless of allow grants, with optional exceptions; they are checked first. Principal access boundary policies attach to sets of principals and limit which resources those principals are eligible to access.

</details>

<details>
<summary>Why should you avoid service account keys, and what replaces them?</summary>

Keys are long-lived secrets that can leak and need rotation. Use attached service accounts on Google Cloud compute, Workload Identity Federation for GKE in clusters, Workload Identity Federation for AWS, Azure or OIDC/SAML workloads such as GitHub Actions, and impersonation for administrators. Use a key only when nothing else works.

</details>

<details>
<summary>What permission is needed to attach a service account to a VM or Cloud Run service?</summary>

`iam.serviceAccounts.actAs` on that service account, granted by the Service Account User role. It stops anyone who can deploy from borrowing a more powerful service account's permissions.

</details>

<details>
<summary>What is the difference between Workload Identity Federation and Workforce Identity Federation?</summary>

Workload Identity Federation lets external workloads (CI systems, other clouds) exchange their own tokens for short-lived Google credentials. Workforce Identity Federation lets human users from an external identity provider access Google Cloud without being synced into Cloud Identity.

</details>

<details>
<summary>How do employees sign in to Google Cloud with existing Active Directory accounts?</summary>

Google Cloud Directory Sync provisions users and groups from Active Directory or LDAP into Cloud Identity, and SAML single sign-on sends authentication to the existing identity provider so passwords stay there. Workforce Identity Federation is an alternative that avoids syncing.

</details>

<details>
<summary>How can operators SSH to VMs that have no external IP addresses without a bastion host?</summary>

Use Identity-Aware Proxy TCP forwarding: IAP checks the user's identity and IAM permissions, then tunnels the connection to the VM's internal address. OS Login ties Linux SSH access to IAM identities instead of per-VM keys.

</details>

## Networking

<details>
<summary>What is global and what is regional in a Google Cloud VPC network?</summary>

The VPC network is global; subnets are regional. VMs in different regions of the same VPC reach each other over internal IPs without VPNs or peering, subject to firewall rules.

</details>

<details>
<summary>Why use custom mode rather than auto mode VPC networks in production?</summary>

Auto mode creates a subnet in every region from fixed ranges in `10.128.0.0/9`, which often overlap with on-premises or other networks. Custom mode lets you plan non-overlapping ranges, including GKE secondary ranges, before connecting networks.

</details>

<details>
<summary>What firewall rules exist in a new custom VPC, and how are firewall policies layered?</summary>

Only implied rules: allow all egress and deny all ingress, at the lowest priority. Hierarchical firewall policies on the organization and folders are evaluated first, then network firewall policies and VPC firewall rules on the network. Rules are stateful, and targeting by service account is stronger than by network tag.

</details>

<details>
<summary>When would you choose Shared VPC over VPC Network Peering?</summary>

Choose Shared VPC when a central team should administer subnets, routes and firewalls while application teams in the same organization keep their own projects. Choose peering to connect a few independently administered VPCs, including across organizations. Peering is not transitive and needs non-overlapping ranges.

</details>

<details>
<summary>How do Private Google Access, Private Service Connect and private services access differ?</summary>

- **Private Google Access**: a subnet setting so internal-only VMs reach Google APIs.
- **Private Service Connect**: an internal IP endpoint in your VPC for Google APIs or a published service; works across organizations and with overlapping ranges.
- **Private services access**: VPC peering with a Google-managed producer network, used by services such as Cloud SQL.

</details>

<details>
<summary>What does Cloud NAT do, and what does it not do?</summary>

It gives private VMs, GKE nodes and serverless egress outbound internet access without external IPs. It is a regional, managed service configured on a Cloud Router, with no NAT VM. It does not accept unsolicited inbound connections and is not needed for Google APIs when Private Google Access is enabled.

</details>

<details>
<summary>How do HA VPN, Dedicated Interconnect, Partner Interconnect and Cross-Cloud Interconnect differ?</summary>

- **HA VPN**: IPsec over the internet with BGP; quick to set up; 99.99% SLA in supported topologies.
- **Dedicated Interconnect**: your own physical circuits at a colocation facility for high bandwidth.
- **Partner Interconnect**: through a service provider when you cannot reach a facility or need less capacity.
- **Cross-Cloud Interconnect**: dedicated links to another cloud provider.

</details>

<details>
<summary>Is Cloud Interconnect traffic encrypted, and which topologies give 99.9% and 99.99% SLAs?</summary>

It is private but not encrypted by default; add MACsec or HA VPN over Cloud Interconnect. 99.9% needs two connections in one metro on different edge availability domains; 99.99% needs four connections across two metros and two regions.

</details>

<details>
<summary>How do Google Cloud and on-premises resolve each other's private DNS names?</summary>

A Cloud DNS forwarding zone sends queries for on-premises domains to on-premises resolvers. An inbound server policy gives on-premises resolvers an address in the VPC to query Cloud DNS private zones. DNS peering shares zones between VPCs.

</details>

<details>
<summary>How do you choose between Application and Network Load Balancers?</summary>

Application Load Balancers are layer 7 proxies for HTTP and HTTPS, with URL routing, Cloud CDN (global external) and Cloud Armor. Network Load Balancers handle TCP, UDP and other protocols: proxy variants terminate connections and can offload TLS, while passthrough variants preserve the client IP and support UDP.

</details>

<details>
<summary>When would you choose a regional external Application Load Balancer over the global one?</summary>

When TLS termination and request processing must stay in one region, for example for data residency, or when the application serves one region and uses the Standard Network Service Tier. The global version terminates at Google's edge worldwide and needs the Premium tier.

</details>

<details>
<summary>What does Cloud Armor provide, and where does it attach?</summary>

Security policies on backend services of external Application Load Balancers and some Network Load Balancers: preconfigured WAF rules based on the OWASP Core Rule Set, IP and geography rules, rate limiting and bot management. Cloud Armor Enterprise adds Adaptive Protection and further DDoS features.

</details>

## Compute

<details>
<summary>How do you choose between Compute Engine, GKE and Cloud Run?</summary>

Compute Engine when you need OS or kernel control, licensed software or lift and shift. GKE when you need Kubernetes: Standard for node control, Autopilot to avoid node management. Cloud Run for stateless containers with the least operations, including scale to zero.

</details>

<details>
<summary>What do managed instance groups provide that unmanaged instance groups do not?</summary>

Identical VMs from an instance template, autoscaling, autohealing based on application health checks, rolling updates and canaries, regional distribution across zones, and stateful configuration. Unmanaged groups only group dissimilar VMs for load balancing.

</details>

<details>
<summary>When should you use Spot VMs, and what is the trade-off?</summary>

For fault-tolerant, restartable work such as batch processing, rendering and CI runners. They are heavily discounted but can be reclaimed at any time with short notice. Unlike legacy preemptible VMs, they have no maximum runtime.

</details>

<details>
<summary>What is the difference between GKE Standard and GKE Autopilot?</summary>

In Standard you manage node pools and pay per node. In Autopilot, Google manages nodes, enforces hardened defaults and bills for the resources Pods request. Autopilot is the usual starting point unless you need node-level control.

</details>

<details>
<summary>What is the difference between Cloud Run services, jobs and worker pools?</summary>

Services handle requests, scale with traffic including to zero, and split traffic between revisions. Jobs run containers to completion, optionally as parallel tasks. Worker pools run long-lived background workloads that do not serve requests, such as pull-based queue consumers.

</details>

<details>
<summary>What are Cloud Run functions, and how are they triggered?</summary>

The current name for Cloud Functions: deploy source code for one function, built and run on Cloud Run. They respond to HTTP requests or to events delivered by Eventarc from sources such as Cloud Storage, Pub/Sub and Cloud Audit Logs.

</details>

## Storage and data

<details>
<summary>What are the Cloud Storage classes and their minimum storage durations?</summary>

Standard (none), Nearline (30 days), Coldline (90 days) and Archive (365 days). All share the same API and millisecond latency; colder classes cost less to store but more to retrieve, and early deletion is charged up to the minimum.

</details>

<details>
<summary>When would you use Autoclass instead of lifecycle rules?</summary>

Use Autoclass when access patterns are unknown or vary per object; it moves each object between classes based on its own access. Use lifecycle rules when the policy is known in advance, such as "Coldline after 90 days, delete after five years".

</details>

<details>
<summary>What are the Cloud Storage location types?</summary>

Region for the lowest latency to compute in that region, dual-region for two specific regions with optional turbo replication, and multi-region for a large geographic area. Dual-region and multi-region survive a regional outage.

</details>

<details>
<summary>How do you protect Cloud Storage objects from deletion and modification?</summary>

Object versioning keeps noncurrent versions after overwrites and deletes, soft delete keeps deleted objects recoverable for a period, and a retention policy locked with Bucket Lock enforces write-once-read-many. Object holds block deletion of individual objects.

</details>

<details>
<summary>How does Hyperdisk differ from Persistent Disk, and which Hyperdisk types exist?</summary>

Hyperdisk provisions capacity, IOPS and throughput separately and is recommended where supported. Types: Balanced (general), Balanced High Availability (synchronous across two zones), Extreme (highest IOPS), Throughput (analytics, cold data) and ML (read-only to many instances). Persistent Disk remains for series without Hyperdisk support.

</details>

<details>
<summary>Which database fits which requirement?</summary>

- **Cloud SQL**: regional MySQL, PostgreSQL or SQL Server.
- **AlloyDB**: PostgreSQL-compatible, higher performance, mixed analytics.
- **Spanner**: relational, strongly consistent, horizontal and multi-region.
- **Bigtable**: wide-column, high-throughput time series and IoT.
- **Firestore**: serverless documents for mobile and web.
- **Memorystore**: in-memory cache.
- **BigQuery**: analytics warehouse.

</details>

<details>
<summary>What is the difference between Cloud SQL high availability and read replicas?</summary>

High availability keeps a synchronous standby in another zone of the same region with automatic failover, protecting against zone failure. Read replicas are asynchronous, can be in other regions, scale reads, and can be promoted manually for disaster recovery.

</details>

<details>
<summary>When is Spanner the right answer, and when is it over-engineering?</summary>

Choose it when a relational workload needs strong consistency, horizontal write scaling or multi-region writes with very high availability; multi-region configurations use the Enterprise Plus edition. For a regional application that fits one primary, Cloud SQL or AlloyDB is simpler and cheaper.

</details>

<details>
<summary>What determines Bigtable performance?</summary>

Row-key design. Rows are sorted by key, so keys that start with a timestamp or sequential value create hotspots. Lead with a well-distributed value, such as a device ID, followed by a timestamp. Bigtable has no joins or multi-row transactions.

</details>

<details>
<summary>When would you choose Dataflow over Managed Service for Apache Spark (formerly Dataproc)?</summary>

Dataflow for new batch or streaming pipelines written in Apache Beam, with serverless autoscaling, windowing and exactly-once processing. Managed Service for Apache Spark to migrate existing Spark or Hadoop jobs with few changes, ideally on short-lived clusters or serverless batches reading from Cloud Storage.

</details>

<details>
<summary>What was Vertex AI renamed to, and how should you approach AI requirements in a design?</summary>

Gemini Enterprise Agent Platform (the v6.1 exam guide still says Vertex AI). Prefer pre-trained APIs or hosted models from Model Garden before custom training. Model Armor screens prompts and responses, and Sensitive Data Protection keeps sensitive data out of training sets and prompts.

</details>

## Reliability and disaster recovery

<details>
<summary>What is the difference between RTO and RPO?</summary>

The recovery time objective is how long a service may be unavailable after a failure. The recovery point objective is how much recent data may be lost, measured in time. Agree both with the business before choosing a design.

</details>

<details>
<summary>What are the cold, warm and hot disaster recovery patterns?</summary>

- **Cold (backup and restore)**: backups only, infrastructure rebuilt from code; hours to days.
- **Warm standby**: a scaled-down copy with replicated data in another region; minutes to hours.
- **Hot (active-active)**: full capacity in several regions; near-zero RTO and RPO, highest cost.

</details>

<details>
<summary>How do zonal, regional and multi-regional designs differ?</summary>

Zonal designs stop if their zone fails. Regional designs (regional MIGs and GKE clusters, Cloud SQL high availability, synchronously replicated disks) survive a zone outage. Multi-regional designs (global load balancing, Spanner multi-region, dual- or multi-region buckets) survive a region outage at higher cost.

</details>

<details>
<summary>What does Backup and DR Service add over ad hoc snapshots?</summary>

Central management of backups for Compute Engine, databases and other workloads, with backup vaults that keep copies immutable and protected from deletion during retention, even by compromised administrators. Keep backups in a separate project and location, and test restores.

</details>

## Security and compliance

<details>
<summary>When do you use default encryption, CMEK, Cloud EKM and CSEK?</summary>

- **Default**: no specific key-control requirement.
- **CMEK**: you must control rotation, disabling and destruction in Cloud KMS.
- **Cloud EKM**: keys must stay outside Google in an external key manager.
- **CSEK**: rare; keys supplied per request, Cloud Storage and Compute Engine only.

</details>

<details>
<summary>What is the difference between Cloud KMS and Secret Manager?</summary>

Cloud KMS holds cryptographic keys and performs operations with them; the key material does not leave it. Secret Manager stores secret values, such as passwords and API keys, as versions that applications read at runtime with per-secret IAM.

</details>

<details>
<summary>What problem does VPC Service Controls solve that IAM does not?</summary>

Data exfiltration with valid credentials. A service perimeter blocks Google API access to services such as Cloud Storage and BigQuery across its boundary, so data cannot be copied to projects outside it. Access levels and ingress or egress rules allow exceptions, and dry-run mode tests a perimeter first.

</details>

<details>
<summary>What do Security Command Center and Binary Authorization do?</summary>

Security Command Center finds misconfigurations, vulnerabilities and threats across an organization and reports compliance against benchmarks such as CIS. Binary Authorization enforces deploy-time policy on GKE and Cloud Run so that only attested images, for example signed by CI, can run.

</details>

<details>
<summary>What are the four types of Cloud Audit Logs?</summary>

- **Admin Activity**: configuration changes; always on, cannot be disabled.
- **Data Access**: reads and user-data access; off by default except BigQuery.
- **System Event**: Google system actions; always on.
- **Policy Denied**: denials by security policies such as VPC Service Controls.

</details>

<details>
<summary>How do you retain audit logs for years in a tamper-resistant way?</summary>

The `_Required` bucket keeps Admin Activity and System Event logs for a fixed 400 days. For longer retention, create an organization-level aggregated sink to a Cloud Storage bucket with a locked retention policy, or to BigQuery for analysis.

</details>

<details>
<summary>How do you enforce data residency and regulatory controls on Google Cloud?</summary>

Use the resource locations organization policy and regional resources. Assured Workloads creates folders with a control package (for example FedRAMP, CJIS or EU data boundary controls) that enforces locations, allowed services and personnel access controls. Compliance remains shared: certified infrastructure does not make a configuration compliant.

</details>

## Operations

<details>
<summary>What are log sinks and aggregated sinks used for?</summary>

The Log Router evaluates sinks that send matching log entries to log buckets, BigQuery, Cloud Storage, Pub/Sub or another project. An aggregated sink at organization or folder level, with child projects included, centralizes logs from every current and future project. Exclusion filters drop low-value logs to control cost.

</details>

<details>
<summary>Which Google Cloud tools answer which observability questions?</summary>

- **Cloud Monitoring**: metrics, dashboards, uptime checks, SLOs and alerting.
- **Cloud Logging**: log storage, routing, log-based metrics and Log Analytics.
- **Error Reporting**: grouped application exceptions.
- **Cloud Trace**: latency across services in a request.
- **Cloud Profiler**: CPU and memory hotspots in code.

</details>

<details>
<summary>What do Cloud Build, Artifact Registry and Cloud Deploy each do?</summary>

Cloud Build runs build steps in containers from triggers, with private pools for private network access. Artifact Registry stores container images and packages, including remote repositories that cache upstream sources; Container Registry is shut down. Cloud Deploy promotes releases through targets with approvals, canaries and rollback.

</details>

<details>
<summary>Which infrastructure as code options does Google Cloud offer today?</summary>

Terraform with the Google provider is the standard. Infrastructure Manager runs Terraform with managed state and execution. Config Connector manages Google Cloud resources as Kubernetes objects. Cloud Deployment Manager reached end of support in March 2026.

</details>

## Cost optimization

<details>
<summary>How do sustained use discounts and committed use discounts differ?</summary>

Sustained use discounts apply automatically to some older series (such as N1, N2, N2D and C2) that run for much of the month; E2 and newer series are not eligible. Committed use discounts require a 1- or 3-year commitment and give larger discounts; usage covered by a commitment does not also receive sustained use discounts.

</details>

<details>
<summary>When would you choose a spend-based flexible commitment over a resource-based commitment?</summary>

Choose spend-based when total spend is predictable but usage moves between regions, machine series, GKE and Cloud Run. Choose resource-based for a known amount of vCPUs, memory or GPUs in one region.

</details>

<details>
<summary>Do budgets stop spending?</summary>

No. Budgets send notifications at thresholds of actual or forecast spend, by email or Pub/Sub. For a hard limit, use quotas or automation triggered by the budget's Pub/Sub messages, such as stopping resources.

</details>

<details>
<summary>How do you reduce BigQuery costs?</summary>

On-demand pricing charges per data scanned, so partition and cluster tables, select only needed columns, set maximum bytes billed and estimate with `bq query --dry_run`. For steady heavy use, editions bill slot capacity with autoscaling, and Enterprise or Enterprise Plus commitments add discounts. Long-term storage pricing applies automatically after 90 days unmodified.

</details>

<details>
<summary>Which network traffic costs money on Google Cloud?</summary>

Ingress is free. Egress between zones and between regions is charged, and internet egress costs more. The Standard Network Service Tier is cheaper than Premium but supports only regional load balancers. Co-locate chatty components and use Cloud CDN for cacheable content.

</details>

## Migration

<details>
<summary>What are the 6 Rs of migration?</summary>

Rehost (lift and shift), replatform (lift and optimize with managed services), refactor or re-architect (change the application), repurchase (replace with SaaS), retire (switch off), and retain (keep where it is for now).

</details>

<details>
<summary>Which Google Cloud tool fits which migration task?</summary>

- **Migration Center**: discovery, utilization and TCO reports.
- **Migrate to Virtual Machines**: VMs from vSphere, AWS or Azure to Compute Engine.
- **Google Cloud VMware Engine**: run VMware workloads unchanged.
- **Database Migration Service**: continuous database migrations to Cloud SQL or AlloyDB.
- **Storage Transfer Service**: online object and file transfers.
- **Transfer Appliance**: offline bulk transfer.

</details>

<details>
<summary>How do you decide between Storage Transfer Service and Transfer Appliance?</summary>

Estimate the online transfer time: data size in bits divided by usable bandwidth. 100 TB over a fully used 1 Gbps link takes about nine days. If that does not fit the schedule, ship a Transfer Appliance; otherwise use Storage Transfer Service, which also supports scheduled incremental syncs from S3, Azure and on-premises.

</details>

## The Well-Architected Framework

<details>
<summary>What are the pillars of the Google Cloud Well-Architected Framework?</summary>

Operational excellence; security, privacy and compliance; reliability; cost optimization; performance optimization; and sustainability. Cross-pillar perspectives, such as AI and ML and financial services, apply the pillars to specific workloads.

</details>

## Answering case-study questions

<details>
<summary>What process helps answer scenario questions on the exam?</summary>

Identify business and technical requirements, then the constraints that eliminate options ("minimal operational overhead", "without code changes", "must stay in the EU"). Choose the simplest managed service that meets them, and reject any answer that ignores a stated constraint, adds unneeded components or breaks least privilege.

</details>

<details>
<summary>Which traps appear most often in Professional Cloud Architect answer options?</summary>

Basic roles, service account keys, self-managed products where a managed one fits, global services when the requirement is regional residency, detection-only controls (alerts, logs) when prevention is required, and extra services that solve a problem the question does not have.

</details>
