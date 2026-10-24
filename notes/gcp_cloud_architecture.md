# Google Cloud architecture for the Professional Cloud Architect exam

The Google Cloud Professional Cloud Architect certification tests whether you can turn business and technical requirements into a secure, reliable, and cost-aware design on Google Cloud. Most questions describe a situation and ask for the best next step, so the skill is choosing between several workable services with a clear reason. This note collects the concepts, comparisons, and defaults that come up most often. Read [cloud fundamentals](cloud.md) first if regions, identity, or service models are new.

Product names and features change. The note uses current names as of 2026 and mentions former names where exam material or older documentation still uses them. Check the linked documentation before implementing a real system.

## The exam

The [v6.1 exam guide](https://cloud.google.com/learn/certification/cloud-architect) weights six sections approximately as follows:

| Section | Approximate weight |
|---|---|
| Designing and planning a cloud solution architecture | 25% |
| Managing and provisioning a solution infrastructure | 18% |
| Designing for security and compliance | 19% |
| Analyzing and optimizing technical and business processes | 15% |
| Managing implementation | 11% |
| Ensuring solution and operations excellence | 12% |

The standard exam lasts two hours and has multiple-choice and multiple-select questions. Some questions refer to case studies that describe fictional companies; the current guide lists Altostrat Media, Cymbal Retail, EHR Healthcare, and KnightMotives Automotive. Read the case studies before the exam so you can recognize their requirements quickly. The guide also expects familiarity with the [Google Cloud Well-Architected Framework](https://docs.cloud.google.com/architecture/framework) and with Google's AI products, which appear in several case studies.

## Resource hierarchy

Google Cloud resources sit in a hierarchy:

1. **Organization**: the root node, tied to a Cloud Identity or Google Workspace domain. Organization administrators can see and govern every project below it.
2. **Folders**: optional groupings, which can be nested, usually for business units, teams, or environments.
3. **Projects**: the basic unit for enabling APIs, billing, quotas, and IAM. Every resource belongs to exactly one project.
4. **Resources**: VMs, buckets, datasets, and so on.

A project has a display name you can change, a globally unique project ID you choose once and cannot change, and a project number assigned by Google. Many APIs and service agents use the number.

Policies set at a node are inherited by everything below it. IAM allow policies are additive: the effective access on a resource is the union of the bindings on the resource and on all its ancestors. A grant made at the folder level therefore cannot be removed by a project administrator. Use [deny policies](#iam) or a different hierarchy placement when a lower level must be excluded.

A common layout puts shared infrastructure (networking, logging, security tooling) in dedicated projects, separates production and non-production in different folders, and uses one project per application per environment. Separate projects give separate quotas, IAM boundaries, and billing reports, and they make deletion of a test environment safe. Google's [enterprise foundations blueprint](https://docs.cloud.google.com/architecture/blueprints/security-foundations) describes a complete landing zone built with Terraform.

### Organization policies

The [Organization Policy Service](https://docs.cloud.google.com/resource-manager/docs/organization-policy/overview) sets guardrails on *what* configurations are allowed, independently of *who* is allowed to act. IAM answers "can this principal call this API"; an organization policy answers "is this configuration allowed anywhere below this node". Policies use constraints, which can be Google-defined (boolean or list) or custom constraints written in Common Expression Language (CEL). They are inherited and can be tested in dry-run mode before enforcement.

Constraints that appear often in designs:

- Restrict resource locations (`gcp.resourceLocations`) for data residency.
- Domain restricted sharing (`iam.allowedPolicyMemberDomains`) so IAM grants go only to principals from approved identities.
- Disable service account key creation and upload.
- Restrict external IP addresses on VMs, require OS Login, or skip creation of the default network.
- Restrict which services can be used, or require CMEK for selected services.

```yaml
# policy.yaml: allow resources only in EU locations for everything under a folder
name: folders/123456789012/policies/gcp.resourceLocations
spec:
  rules:
  - values:
      allowedValues:
      - in:eu-locations
```

Apply it with `gcloud org-policies set-policy policy.yaml`.

### Labels and tags

Labels are key-value metadata on resources. They appear in billing export data and are the usual way to attribute cost to teams, applications, or environments. They do not control access.

Tags (Resource Manager tags) are separate resources defined at the organization or project level and bound to resources. They are inherited down the hierarchy and can be referenced in IAM conditions, organization policy conditions, and network firewall policies (as secure tags). Network tags on VMs are an older, unrelated mechanism used only by VPC firewall rules and routes.

### Billing accounts

A Cloud Billing account pays for one or more projects; each project links to at most one billing account. The Billing Account Administrator role manages the account, the Billing Account User role allows linking projects to it, and the Project Billing Manager role allows changing a project's link. Export billing data to BigQuery for analysis, and use budgets for notifications (see [cost](#cost-optimization)).

## IAM

[Identity and Access Management](https://docs.cloud.google.com/iam/docs/overview) decides who (a principal) can do what (a role, which is a set of permissions) on which resource. An allow policy attached to a resource contains role bindings; each binding lists principals, one role, and an optional condition.

Principals include Google accounts, service accounts, Google groups, Google Workspace or Cloud Identity domains, federated identities, and the special values `allUsers` and `allAuthenticatedUsers`, which make a resource public. Grant roles to groups rather than individuals so that joining and leaving a team is an identity change, not a policy change.

### Role types

| Role type | Description | Use |
|---|---|---|
| Basic | Owner, Editor, Viewer; thousands of permissions across all services | Avoid in production; acceptable only in small sandboxes |
| Predefined | Maintained by Google per service, such as `roles/storage.objectViewer` | Default choice; pick the narrowest role that works |
| Custom | A permission list you define at organization or project level | When no predefined role is narrow enough; you must maintain it as services add permissions |

Least privilege means granting the narrowest role on the lowest resource that satisfies the requirement, for the shortest needed time. [IAM recommender](https://docs.cloud.google.com/policy-intelligence/docs/role-recommendations-overview) suggests removing unused permissions, Policy Analyzer answers "who can access this resource", and Policy Troubleshooter explains why a request was allowed or denied.

### Conditions, deny policies, and access boundaries

[IAM Conditions](https://docs.cloud.google.com/iam/docs/conditions-overview) restrict a binding by attributes such as request time, resource name prefix, resource type, or tags. Typical uses are temporary access that expires automatically and access limited to resources with a specific tag.

[Deny policies](https://docs.cloud.google.com/iam/docs/deny-overview) block listed permissions for listed principals regardless of what allow policies grant, and can carry exceptions. They are evaluated before allow policies. Use them for guardrails such as "nobody except the security group may delete projects in this folder".

[Principal access boundary policies](https://docs.cloud.google.com/iam/docs/principal-access-boundary-policies) are attached to sets of principals rather than resources and limit which resources those principals are eligible to access. Like deny policies, they cannot grant access.

```bash
# Grant temporary read access that expires at the end of 2026
gcloud projects add-iam-policy-binding my-project \
  --member="group:auditors@example.com" \
  --role="roles/viewer" \
  --condition='expression=request.time < timestamp("2027-01-01T00:00:00Z"),title=expires-2026'
```

### Service accounts and workload identity

A service account is an identity for a workload. Attach a user-managed service account with only the roles the workload needs; avoid the default Compute Engine service account, which historically received the Editor role. To attach a service account to a resource, the deployer needs `iam.serviceAccounts.actAs`, granted by the Service Account User role. Service agents are Google-managed service accounts that let a Google service act in your project.

Service account keys are long-lived secrets that can leak and must be rotated. Prefer credentials that Google issues automatically and that expire:

| Workload location | Recommended credential |
|---|---|
| Compute Engine, Cloud Run, Cloud Run functions | Attached service account, tokens from the metadata server |
| GKE | [Workload Identity Federation for GKE](https://docs.cloud.google.com/kubernetes-engine/docs/concepts/workload-identity) (formerly Workload Identity), mapping Kubernetes service accounts to IAM |
| AWS, Azure, GitHub Actions, GitLab, other OIDC or SAML issuers | [Workload Identity Federation](https://docs.cloud.google.com/iam/docs/workload-identity-federation), exchanging the external token for a short-lived Google token |
| An administrator needing elevated rights | Service account impersonation with the Service Account Token Creator role, which is logged |
| Third-party system that only supports a key file | A key as a last resort, with an expiry, rotation, and an owner |

Workforce Identity Federation does the same for human users from an external identity provider without syncing them into Cloud Identity. Alternatively, Google Cloud Directory Sync copies users and groups from Active Directory or LDAP into Cloud Identity, and SAML single sign-on keeps passwords in the existing identity provider.

### Secure remote access

[Identity-Aware Proxy (IAP)](https://docs.cloud.google.com/iap/docs/concepts-overview) checks identity and context before forwarding requests to an application behind a load balancer, and its TCP forwarding allows SSH or RDP to VMs without external IP addresses or a bastion host. Chrome Enterprise Premium (formerly BeyondCorp Enterprise) adds context-aware access based on device posture and location. OS Login ties SSH access on Linux VMs to IAM identities instead of per-VM keys.

## Networking

A [VPC network](https://docs.cloud.google.com/vpc/docs/vpc) is a global resource; its subnets are regional. VMs in different regions of the same VPC communicate over internal IP addresses without extra configuration. Use custom mode VPCs in production so you control subnet ranges; auto mode creates a subnet in every region with fixed ranges that often overlap with on-premises networks. Plan non-overlapping RFC 1918 ranges early, including secondary ranges for GKE Pods and Services.

Routes decide where packets go: subnet routes are automatic, a default route sends traffic to the internet gateway, and custom static or dynamic routes (learned by Cloud Router over BGP) handle hybrid and appliance paths. A VPC's dynamic routing mode is regional (routes learned in a region apply only there) or global.

### Firewalls

Firewall rules are stateful, so return traffic for an allowed connection is permitted. Every VPC has implied rules that deny all ingress and allow all egress, at the lowest priority. [Cloud Next Generation Firewall](https://docs.cloud.google.com/firewall/docs/about-firewalls) offers several rule containers:

- **Hierarchical firewall policies** attached to the organization or folders, evaluated first. Use them for rules that every project must follow, such as allowing health-check ranges or blocking known-bad sources; a rule can delegate the decision to lower levels with `goto_next`.
- **Global and regional network firewall policies** attached to VPC networks, which can use secure tags and FQDN or geolocation objects.
- **VPC firewall rules** on a single network, targeting VMs by network tag or service account. Targeting by service account is stronger because changing it requires IAM permissions.

Cloud NGFW has Essentials, Standard, and Enterprise tiers; Enterprise adds intrusion detection and prevention and URL filtering on traffic inspected by Google-managed firewall endpoints.

### Connecting VPC networks

| Option | What it does | Choose it when |
|---|---|---|
| [Shared VPC](https://docs.cloud.google.com/vpc/docs/shared-vpc) | A host project owns the network; service projects in the same organization create resources in its subnets | A central network team controls subnets, routes, and firewalls while application teams keep their own projects |
| [VPC Network Peering](https://docs.cloud.google.com/vpc/docs/vpc-peering) | Connects two VPCs, also across organizations, using internal IPs | A small number of VPCs need private connectivity and each side keeps its own administration |
| [Network Connectivity Center](https://docs.cloud.google.com/network-connectivity/docs/network-connectivity-center/concepts/overview) | Hub-and-spoke connectivity between many VPCs and hybrid connections | Many VPCs or sites need transitive connectivity managed in one place |

Peering is not transitive: if A peers with B and B with C, A cannot reach C through B. Peered ranges must not overlap, and each side manages its own firewalls. Shared VPC is the usual answer for "centralized network administration with decentralized project ownership".

### Reaching Google services and published services privately

- **Private Google Access** is a subnet setting that lets VMs without external IP addresses reach Google APIs such as Cloud Storage and BigQuery.
- **[Private Service Connect](https://docs.cloud.google.com/vpc/docs/private-service-connect)** creates an endpoint with an internal IP address in your VPC for Google APIs or for a service published by another organization or team. It works across organizations and with overlapping IP ranges because traffic is translated at the endpoint.
- **Private services access** reserves a range and peers your VPC with a Google-managed producer network. Older Cloud SQL, Memorystore, and Filestore designs use it; several of these services now also support Private Service Connect.
- **Serverless egress**: Cloud Run can send traffic into a VPC with Direct VPC egress or a Serverless VPC Access connector.

[Cloud NAT](https://docs.cloud.google.com/nat/docs/overview) gives private VMs, GKE nodes, and serverless egress outbound internet access without external IP addresses. It is a regional, software-defined service configured on a Cloud Router; there is no NAT VM to manage, and it does not allow unsolicited inbound connections.

```bash
gcloud compute networks create prod-vpc --subnet-mode=custom
gcloud compute networks subnets create app-euw1 --network=prod-vpc \
  --region=europe-west1 --range=10.10.0.0/20 --enable-private-ip-google-access
gcloud compute routers create nat-router --network=prod-vpc --region=europe-west1
gcloud compute routers nats create nat-euw1 --router=nat-router --region=europe-west1 \
  --auto-allocate-nat-external-ips --nat-all-subnet-ip-ranges
```

### Hybrid and multicloud connectivity

[Cloud Router](https://docs.cloud.google.com/network-connectivity/docs/router/concepts/overview) exchanges routes with on-premises or other-cloud routers over BGP; it is a control-plane service, not a data-path appliance.

| Option | Characteristics | Choose it when |
|---|---|---|
| [HA VPN](https://docs.cloud.google.com/network-connectivity/docs/vpn/concepts/overview) | IPsec over the internet, BGP via Cloud Router, two interfaces; 99.99% SLA in supported topologies | Quick, encrypted connectivity with moderate bandwidth, or as backup for Interconnect |
| Classic VPN | Static routing, single interface, 99.9% SLA | Only legacy setups; migrate to HA VPN |
| [Dedicated Interconnect](https://docs.cloud.google.com/network-connectivity/docs/interconnect/concepts/dedicated-overview) | Physical circuits between your router and Google at a colocation facility | High, predictable bandwidth and you can reach a supported facility |
| Partner Interconnect | Connectivity through a supported service provider, with a range of capacities | You cannot reach a colocation facility or need less than a full circuit |
| Cross-Cloud Interconnect | Dedicated physical connection between Google Cloud and another cloud provider | Private, high-bandwidth multicloud links |

Interconnect traffic is private but not encrypted by default. Add MACsec on supported circuits or run HA VPN over Cloud Interconnect when encryption is required. For an Interconnect SLA, the documented topologies are: 99.9% with two connections in one metropolitan area on different edge availability domains, and 99.99% with four connections across two metropolitan areas and two regions. Direct Peering and Carrier Peering reach Google's public services, such as Google Workspace, and do not give private access to VPC resources.

### Cloud DNS

[Cloud DNS](https://docs.cloud.google.com/dns/docs/overview) hosts public zones (with DNSSEC) and private zones visible to chosen VPCs. Hybrid name resolution uses forwarding zones (Google Cloud resolves on-premises names by forwarding to on-premises DNS servers) and inbound server policies (on-premises resolvers query Google Cloud private zones). DNS peering lets one VPC use another VPC's zones, which is common with Shared VPC and hub designs. Routing policies (weighted, geolocation, failover) support simple traffic steering.

### Load balancing

[Cloud Load Balancing](https://docs.cloud.google.com/load-balancing/docs/load-balancing-overview) is a software-defined, managed service. Families are divided by layer (Application for HTTP and HTTPS, Network for TCP, UDP, and other protocols), by exposure (external or internal), and by scope (global, regional, or cross-region internal).

| Requirement | Load balancer |
|---|---|
| HTTP(S) for users worldwide, one anycast IP, CDN, WAF | Global external Application Load Balancer |
| HTTP(S) that must stay in one region, for example for residency | Regional external Application Load Balancer |
| Internal HTTP(S) between services in one region | Regional internal Application Load Balancer |
| Internal HTTP(S) with backends in several regions and failover | Cross-region internal Application Load Balancer |
| TCP with TLS offload for global clients, non-HTTP | Global external proxy Network Load Balancer |
| TCP or UDP, client source IP preserved, any port | External passthrough Network Load Balancer |
| Internal TCP or UDP, or next hop for network appliances | Internal passthrough Network Load Balancer |

Passthrough load balancers do not terminate connections, so backends see the original client IP and respond directly. Proxy load balancers terminate the client connection and open a new one to the backend. Global external load balancers require the Premium Network Service Tier, which carries traffic on Google's network to the edge closest to the user.

[Cloud Armor](https://docs.cloud.google.com/armor/docs/cloud-armor-overview) attaches security policies to backend services of external Application Load Balancers and several Network Load Balancers. It provides preconfigured WAF rules based on the OWASP Core Rule Set, IP and geography allow and deny lists, rate limiting, and bot management. Cloud Armor Enterprise adds Adaptive Protection, which detects layer 7 attacks and suggests rules, and further DDoS features. [Cloud CDN](https://docs.cloud.google.com/cdn/docs/overview) caches content at Google's edge for the global external Application Load Balancer, with backend services or Cloud Storage backend buckets as origins, and supports signed URLs for restricted content.

## Compute

Choose the most managed option that meets the workload's requirements for control, runtime, and scaling.

| Requirement | Service |
|---|---|
| Full OS control, custom kernels, licensed software, lift and shift | [Compute Engine](https://docs.cloud.google.com/compute/docs/overview) |
| Kubernetes with control over nodes, node images, and special hardware | [GKE](https://docs.cloud.google.com/kubernetes-engine/docs/concepts/kubernetes-engine-overview) Standard |
| Kubernetes without managing nodes, paying for requested Pod resources | GKE Autopilot |
| Stateless HTTP, gRPC, or event-driven containers that scale to zero | [Cloud Run](https://docs.cloud.google.com/run/docs/overview/what-is-cloud-run) services |
| Containerized batch tasks that run to completion | Cloud Run jobs |
| Long-running background workers that do not serve requests | Cloud Run worker pools |
| Small single-purpose code triggered by events or HTTP | [Cloud Run functions](https://docs.cloud.google.com/run/docs/functions/comparison) (formerly Cloud Functions) |
| Existing App Engine applications | App Engine standard or flexible environment |
| VMware workloads moved without re-platforming | Google Cloud VMware Engine |

Google recommends Cloud Run rather than App Engine for new web applications. App Engine remains supported, and exam questions may still mention it for existing applications.

### Compute Engine

Machine families include general-purpose (E2, N-series, C-series), compute-optimized, memory-optimized (for very large in-memory databases such as SAP HANA), storage-optimized, and accelerator-optimized (GPUs). Custom machine types set vCPU and memory independently when predefined shapes waste resources. Shielded VM protects boot integrity; Confidential VM encrypts memory in use. Google live-migrates most VMs during host maintenance.

[Managed instance groups (MIGs)](https://docs.cloud.google.com/compute/docs/instance-groups) create identical VMs from an instance template. They provide:

- **Autoscaling** on CPU utilization, load balancer serving capacity, Cloud Monitoring metrics, or schedules.
- **Autohealing** that recreates VMs failing an application health check.
- **Rolling updates and canaries** to a new template, with surge and unavailability limits.
- **Regional MIGs** that spread VMs across zones in a region; prefer them over zonal MIGs for availability.
- **Stateful MIGs** that preserve disks and names for workloads that need them.

Unmanaged instance groups only group dissimilar VMs behind a load balancer; they do not autoscale or autoheal.

[Spot VMs](https://docs.cloud.google.com/compute/docs/instances/spot) use spare capacity at a large discount and can be stopped or deleted at any time with a short notice. Use them for fault-tolerant, restartable work such as batch processing, rendering, or CI runners, often in a MIG or GKE node pool next to standard capacity. Unlike legacy preemptible VMs they have no maximum runtime. [Sole-tenant nodes](https://docs.cloud.google.com/compute/docs/nodes/sole-tenant-nodes) dedicate a physical server to your project for isolation requirements or bring-your-own-license terms tied to physical cores.

```bash
gcloud compute instance-templates create web-v2 --machine-type=e2-standard-4 \
  --image-family=debian-12 --image-project=debian-cloud \
  --service-account=web@my-project.iam.gserviceaccount.com --scopes=cloud-platform --no-address
gcloud compute instance-groups managed create web-mig --template=web-v2 \
  --size=3 --region=europe-west1 --health-check=web-hc --initial-delay=120
gcloud compute instance-groups managed set-autoscaling web-mig --region=europe-west1 \
  --min-num-replicas=3 --max-num-replicas=20 --target-cpu-utilization=0.6
```

Patch VMs with VM Manager OS patch management, or rebuild images and roll them out through the MIG so that instances stay immutable.

### GKE

In GKE Standard you manage node pools (machine types, autoscaling, upgrades within release channels) and pay for nodes. In Autopilot, Google manages nodes, applies hardened defaults, and bills for the CPU, memory, and storage that Pods request; it is the recommended starting mode when you do not need node-level control. Regional clusters replicate the control plane and nodes across zones; zonal clusters have a single-zone control plane. Use private nodes, Workload Identity Federation for GKE, release channels, and Binary Authorization for production clusters. Scaling uses the Horizontal Pod Autoscaler for replicas, the Vertical Pod Autoscaler for requests, and the cluster autoscaler or node auto-provisioning for nodes. See [containers and orchestration](containers_and_orchestration.md) for the underlying concepts.

### Cloud Run and functions

Cloud Run runs containers on a fully managed platform. A service handles requests with configurable concurrency per instance, scales to zero, and can keep minimum instances warm to reduce cold starts. Each deployment creates a revision, and traffic can be split between revisions for gradual rollouts. Cloud Run jobs execute tasks in parallel until completion and suit scheduled or ad hoc batch work. Cloud Run functions deploy source code for one function, built and run on Cloud Run, and receive events through Eventarc from sources such as Cloud Storage, Pub/Sub, and Cloud Audit Logs.

```bash
gcloud run deploy orders --image=europe-west1-docker.pkg.dev/my-project/apps/orders:1.4.0 \
  --region=europe-west1 --service-account=orders@my-project.iam.gserviceaccount.com \
  --no-allow-unauthenticated --min-instances=1
```

## Storage and data

### Cloud Storage

[Cloud Storage](https://docs.cloud.google.com/storage/docs/introduction) stores objects in buckets. All storage classes use the same API and have millisecond first-byte latency; they differ in storage price, retrieval charges, and minimum storage duration.

| Class | Minimum storage duration | Typical access pattern |
|---|---|---|
| Standard | None | Frequently accessed or short-lived data |
| Nearline | 30 days | About once a month or less, such as backups |
| Coldline | 90 days | About once a quarter or less, such as disaster recovery copies |
| Archive | 365 days | Less than once a year, such as regulatory archives |

Location types are region (lowest latency to regional compute), dual-region (two specific regions, optional turbo replication for a faster replication target), and multi-region (a large geographic area). [Object Lifecycle Management](https://docs.cloud.google.com/storage/docs/lifecycle) changes class or deletes objects by age, version count, or other conditions. [Autoclass](https://docs.cloud.google.com/storage/docs/autoclass) moves each object between classes based on its access pattern, which suits unknown or mixed access patterns.

Protect data with object versioning, soft delete (deleted objects are recoverable for a retention period), retention policies with Bucket Lock for write-once-read-many requirements, and object holds. Use uniform bucket-level access so IAM alone controls access, and signed URLs to give time-limited access to someone without a Google identity.

### Block and file storage

- **[Hyperdisk](https://docs.cloud.google.com/compute/docs/disks/hyperdisks)** is the recommended block storage on machine series that support it. Capacity, IOPS, and throughput are provisioned separately. Types are Balanced (general purpose), Balanced High Availability (synchronous replication across two zones), Extreme (highest IOPS for large databases), Throughput (scale-out analytics and cold data), and ML (read-only attachment to many instances for model data). Storage pools buy capacity and performance in bulk.
- **Persistent Disk** (Standard, Balanced, SSD, Extreme) remains for machine series without Hyperdisk support. Regional Persistent Disk replicates synchronously across two zones.
- **Local SSD** is physically attached, very fast, and ephemeral; use it for caches and scratch data that can be rebuilt.
- **Snapshots** are incremental and can be stored in multi-region locations for recovery in another region. Asynchronous replication copies disks continuously to a second region.
- **[Filestore](https://docs.cloud.google.com/filestore/docs/overview)** provides managed NFS file shares for applications that need a shared POSIX file system. Google Cloud NetApp Volumes covers NFS and SMB with enterprise storage features.

### Choosing a database

| Need | Service |
|---|---|
| Relational MySQL, PostgreSQL, or SQL Server, regional, lift and shift | [Cloud SQL](https://docs.cloud.google.com/sql/docs/introduction) |
| PostgreSQL-compatible with higher performance and mixed analytical queries | [AlloyDB for PostgreSQL](https://docs.cloud.google.com/alloydb/docs/overview) |
| Relational, strongly consistent, horizontal scale, multi-region writes | [Spanner](https://docs.cloud.google.com/spanner/docs/overview) |
| Wide-column, very high write throughput, low latency on a row key, time series or IoT | [Bigtable](https://docs.cloud.google.com/bigtable/docs/overview) |
| Serverless document database for mobile, web, and user data | [Firestore](https://docs.cloud.google.com/firestore/docs/overview) |
| In-memory cache or session store (Valkey, Redis, Memcached) | [Memorystore](https://docs.cloud.google.com/memorystore/docs) |
| Serverless data warehouse for SQL analytics over large datasets | [BigQuery](https://docs.cloud.google.com/bigquery/docs/introduction) |

Details that often decide a question:

- **Cloud SQL** high availability uses a standby in another zone of the same region with synchronous replication and automatic failover. Read replicas are asynchronous and can be in other regions; promote a cross-region replica for disaster recovery. Enterprise Plus edition offers a higher SLA and near-zero downtime maintenance. Scaling writes beyond one primary requires a different database.
- **AlloyDB** separates compute and storage, adds read pool instances and a columnar engine, and keeps PostgreSQL compatibility.
- **Spanner** provides external consistency and transactions across regions. Multi-region configurations, with the highest availability SLA, require the Enterprise Plus edition. It is the answer when a relational workload must scale globally with strong consistency, and usually over-engineered otherwise.
- **Bigtable** has no SQL joins or multi-row transactions; performance depends on row-key design that avoids hotspots. It suits telemetry, financial ticks, and personalization data.
- **Firestore** offers real-time listeners, offline client support, and automatic scaling. Datastore mode serves server-side applications that used Cloud Datastore.
- **BigQuery** separates storage and compute. Partition and cluster tables so queries scan less data, and use it for analytics, not as a transactional backend.

### Messaging and data processing

- **[Pub/Sub](https://docs.cloud.google.com/pubsub/docs/overview)** is a global asynchronous messaging service with push and pull subscriptions, at-least-once delivery by default, optional ordering keys, exactly-once delivery for pull subscriptions, dead-letter topics, and message retention for replay. It decouples producers from consumers and absorbs bursts.
- **[Dataflow](https://docs.cloud.google.com/dataflow/docs/overview)** runs Apache Beam pipelines for batch and streaming with autoscaling, windowing, and exactly-once processing. Choose it for new pipelines, especially streaming from Pub/Sub into BigQuery.
- **[Managed Service for Apache Spark](https://docs.cloud.google.com/dataproc/docs/concepts/overview)** (formerly Dataproc, including the serverless option previously called Serverless for Apache Spark) runs Spark, Hadoop, and related open-source jobs. Choose it to migrate existing Spark or Hadoop jobs with few changes; keep data in Cloud Storage and use short-lived clusters or serverless batches instead of permanent clusters.
- **Managed Service for Apache Airflow** (formerly Cloud Composer) orchestrates multi-step workflows across services. Datastream replicates database changes into BigQuery or Cloud Storage, and the BigQuery Data Transfer Service schedules loads from SaaS sources and other warehouses.

### AI and machine learning

Exam case studies increasingly include generative AI. Know the positioning rather than every feature. Gemini Enterprise Agent Platform (formerly Vertex AI, still named that in the v6.1 exam guide) provides managed training, pipelines, model serving endpoints, a feature store, and Model Garden for Gemini, open, and third-party models. Pre-trained APIs (Vision, Speech-to-Text, Translation, Natural Language) solve common tasks without training a model. Gemini Enterprise gives employees agents and enterprise search. Model Armor screens prompts and responses, and [Sensitive Data Protection](https://docs.cloud.google.com/sensitive-data-protection/docs/sensitive-data-protection-overview) discovers and de-identifies sensitive data before it reaches training sets or prompts. Prefer a pre-trained API or a hosted model over custom training when it meets the requirement.

## Reliability and disaster recovery

A zone is a failure domain within a region; a region is a set of zones in one geographic area. Designs move up in availability, cost, and complexity:

- **Zonal**: a single VM or zonal cluster. A zone outage stops the service.
- **Regional**: regional MIGs, regional GKE clusters, Cloud SQL high availability, regional or Hyperdisk Balanced High Availability disks, regional Cloud Storage. Survives a zone outage.
- **Multi-regional**: global load balancing over several regions, Spanner multi-region, dual-region or multi-region Cloud Storage, Bigtable replication, cross-region database replicas. Survives a region outage, at the cost of replication and data consistency decisions.

Define availability with service-level indicators and objectives as described in [observability](observability.md). When a request depends on several components in series, the combined availability is roughly the product of their availabilities, so a chain of 99.9% services is less available than any one of them. Redundancy and graceful degradation recover availability.

### Recovery objectives and patterns

The recovery time objective (RTO) is how long the service may be unavailable; the recovery point objective (RPO) is how much recent data may be lost. Decide both with the business, then pick the cheapest pattern that meets them. See [backup and recovery](backup_and_recovery.md) for restore drills.

| Pattern | Description | RTO and RPO | Google Cloud examples |
|---|---|---|---|
| Backup and restore (cold) | Data is backed up; infrastructure is recreated after a disaster | Hours to days; RPO equals backup interval | Snapshots, Cloud SQL backups, Cloud Storage in another region, infrastructure as code to rebuild |
| Warm standby | A scaled-down copy runs in the recovery region with replicated data | Minutes to hours; RPO near replication lag | Cross-region Cloud SQL replica, small MIG ready to resize, DNS or load balancer failover |
| Hot (active-active) | Full capacity serves traffic in several regions | Near zero | Global external Application Load Balancer, Spanner multi-region, multi-region Cloud Storage |

[Backup and DR Service](https://docs.cloud.google.com/backup-disaster-recovery/docs/concepts/backup-dr) centrally manages backups for Compute Engine, databases, and other workloads, including backup vaults that protect copies from deletion or modification by compromised administrators. Store backups in a different project and location from the workload, test restores regularly, and include the infrastructure code and secrets needed to rebuild. Practise failover with game days, and use chaos testing, load testing, and penetration testing to validate assumptions before an incident does.

## Security and compliance

### Encryption and keys

Google encrypts all data at rest by default with Google-owned and Google-managed keys, and encrypts data in transit between its facilities.

| Option | Who controls the key | Use when |
|---|---|---|
| Default encryption | Google | No specific key-control requirement |
| [Customer-managed encryption keys (CMEK)](https://docs.cloud.google.com/kms/docs/cmek) | You, in Cloud KMS (software, Cloud HSM, or external) | You must control rotation, disable or destroy keys, or separate key administration from data access |
| Cloud External Key Manager | You, in a supported key manager outside Google | Regulations require keys to stay outside the provider |
| Customer-supplied encryption keys (CSEK) | You, sent with each request | Rare; Cloud Storage and Compute Engine only, and losing the key loses the data |

[Cloud KMS](https://docs.cloud.google.com/kms/docs/key-management-service) holds keys and performs cryptographic operations; key material does not leave it. Separate the roles of key administrator and key user (Cloud KMS CryptoKey Encrypter/Decrypter) for separation of duties. Cloud KMS Autokey creates CMEK keys automatically when resources are created. Cloud HSM keeps keys in FIPS 140-2 Level 3 validated hardware.

[Secret Manager](https://docs.cloud.google.com/secret-manager/docs/overview) stores API keys, passwords, and certificates as versioned secrets with per-secret IAM, audit logs, rotation reminders through Pub/Sub, and optional CMEK. Applications read secrets at runtime with their service account; secrets do not belong in images, environment files in Git, or instance metadata. See [security and secrets](security_and_secrets.md) for general practice.

### Perimeters, posture, and supply chain

- **[VPC Service Controls](https://docs.cloud.google.com/vpc-service-controls/docs/overview)** places projects in a service perimeter so that Google-managed services such as Cloud Storage and BigQuery cannot be accessed from outside it, even with valid credentials. It mitigates data exfiltration and stolen credentials. Access levels from Access Context Manager admit specific IP ranges or devices, ingress and egress rules allow controlled exceptions, and dry-run mode shows what would be blocked.
- **[Security Command Center](https://docs.cloud.google.com/security-command-center/docs/security-command-center-overview)** finds misconfigurations, vulnerabilities, and threats across an organization and reports compliance against benchmarks such as CIS. Premium adds threat detection services and attack path analysis.
- **[Binary Authorization](https://docs.cloud.google.com/binary-authorization/docs/overview)** enforces deploy-time policy on GKE and Cloud Run, for example allowing only images signed by the build pipeline after passing vulnerability scanning in Artifact Analysis.
- **Sensitive Data Protection** inspects, classifies, masks, and tokenizes sensitive data such as card numbers. For PCI DSS designs, minimise and isolate the systems that handle cardholder data in their own projects.

### Cloud Audit Logs

| Log type | Records | Enabled |
|---|---|---|
| Admin Activity | API calls that change configuration or metadata | Always on, cannot be disabled, no charge |
| Data Access | Reads of configuration and reads or writes of user data | Off by default except for BigQuery; enable per service, can be voluminous |
| System Event | Google system actions that change resources, such as live migration | Always on, no charge |
| Policy Denied | Access denied because of a security policy such as VPC Service Controls | Generated by default; can be excluded |

Admin Activity and System Event logs go to the `_Required` log bucket, which has a fixed 400-day retention. Other logs go to the `_Default` bucket, whose retention you can change. For longer or tamper-resistant retention, use an aggregated sink at the organization level to Cloud Storage with a locked retention policy or to BigQuery for analysis. [Access Transparency](https://docs.cloud.google.com/assured-workloads/access-transparency/docs/overview) logs actions taken by Google personnel, and Access Approval requires your approval before such access.

### Compliance and data residency

Compliance is shared: Google provides certified infrastructure and contractual commitments such as a HIPAA business associate agreement, and you configure services, access, and processes correctly. Enforce residency with the resource locations organization policy and regional resources. [Assured Workloads](https://docs.cloud.google.com/assured-workloads/docs/overview) creates folders with a control package (for example FedRAMP, CJIS, or EU data boundary controls) that applies location restrictions, approved services, and personnel access controls. Keep audit evidence in logs and infrastructure code so that auditors can trace who changed what.

## Operations

### Observability

- **[Cloud Monitoring](https://docs.cloud.google.com/monitoring/docs/monitoring-overview)** collects metrics from Google services, the Ops Agent on VMs, and Google Cloud Managed Service for Prometheus. It provides dashboards, uptime checks, SLO monitoring, and alerting policies with notification channels. A metrics scope lets one project view metrics from many projects.
- **[Cloud Logging](https://docs.cloud.google.com/logging/docs/overview)** stores logs in log buckets. The Log Router evaluates sinks that send matching entries to log buckets, BigQuery, Cloud Storage, Pub/Sub, or another project. Aggregated sinks at organization or folder level centralise logs from all child projects; exclusion filters drop low-value logs to control cost. Log-based metrics turn log patterns into alertable metrics, and Log Analytics queries logs with SQL.
- **Error Reporting** groups application exceptions; **Cloud Trace** shows request latency across services; **Cloud Profiler** shows CPU and memory hotspots in production code. Gemini Cloud Assist helps investigate issues and suggests configurations in the console.

```bash
# Send all audit logs from every project in the organization to a central bucket
gcloud logging sinks create org-audit-sink \
  storage.googleapis.com/example-org-audit-logs \
  --organization=123456789012 --include-children \
  --log-filter='logName:"cloudaudit.googleapis.com"'
```

The sink's writer identity must then be granted permission to write to the destination.

### Delivery

- **[Cloud Build](https://docs.cloud.google.com/build/docs/overview)** runs build steps in containers, triggered by repository events. Private pools run builds with access to private networks.
- **[Artifact Registry](https://docs.cloud.google.com/artifact-registry/docs/overview)** stores container images and language packages in regional or multi-regional repositories, with remote repositories that cache upstream sources and virtual repositories that combine several. Container Registry is shut down; `gcr.io` addresses are served by Artifact Registry.
- **[Cloud Deploy](https://docs.cloud.google.com/deploy/docs/overview)** promotes releases through a delivery pipeline of targets (for example dev, staging, prod on GKE or Cloud Run), with approvals, canary deployments, and rollback.

Rolling updates replace instances gradually, blue/green switches traffic between two complete environments, and canary releases expose a small share of traffic first. Compare them in [CI/CD](ci_cd.md) and [canary releases](canary_release.md).

### Infrastructure as code and tooling

Terraform with the Google provider is the standard for repeatable infrastructure; see [Terraform and infrastructure as code](terraform_and_iac.md). [Infrastructure Manager](https://docs.cloud.google.com/infrastructure-manager/docs/overview) runs Terraform for you with managed state and Cloud Build execution. Cloud Deployment Manager reached end of support in March 2026; migrate its templates to Terraform. Config Connector manages Google Cloud resources as Kubernetes objects for teams that operate through GKE.

Interact programmatically with `gcloud`, `gcloud storage` (preferred over the older `gsutil`), and `bq`, from Cloud Shell or a workstation, and with Google API client libraries that use Application Default Credentials. Local emulators for Pub/Sub, Firestore, Bigtable, and Spanner support tests without cloud resources. For API management, Apigee provides API proxies with quotas, security policies, analytics, monetization, and a developer portal; API Gateway is a lighter option in front of serverless backends.

## Cost optimization

Compute Engine bills per second after a short minimum. Discounts and pricing models:

| Model | How it works | Fits |
|---|---|---|
| [Sustained use discounts](https://docs.cloud.google.com/compute/docs/sustained-use-discounts) | Applied automatically when eligible VMs run for a large part of the month; only some older series such as N1, N2, N2D, and C2, not E2 or newer series | Steady usage without commitment |
| Resource-based [committed use discounts](https://docs.cloud.google.com/compute/docs/instances/committed-use-discounts-overview) | Commit to vCPUs, memory, GPUs, or other resources in one region for 1 or 3 years; billed whether used or not, cannot be cancelled | Predictable baseline on a known machine series |
| Spend-based (flexible) committed use discounts | Commit to an hourly spend for 1 or 3 years across eligible Compute Engine, GKE, and Cloud Run usage, not tied to region or machine series | Predictable spend whose shape may change |
| Spot VMs | Deep discount, can be reclaimed at any time | Fault-tolerant batch and stateless work |

Sustained use discounts do not apply to usage already covered by committed use discounts. Other levers include rightsizing recommendations, custom machine types, scheduling non-production VMs off at night, scale-to-zero serverless services, deleting unattached disks and idle IP addresses, and lifecycle rules or Autoclass for storage.

[Budgets and alerts](https://docs.cloud.google.com/billing/docs/how-to/budgets) notify at thresholds of actual or forecast spend, by email or Pub/Sub for automation. A budget does not stop spending; use quotas to cap resource usage, or a Pub/Sub-triggered function that takes an action such as stopping resources when a hard limit is required. Export billing to BigQuery and attribute costs with labels and projects.

**BigQuery** compute is priced on-demand (per amount of data scanned by each query) or through [editions](https://docs.cloud.google.com/bigquery/docs/editions-intro) (Standard, Enterprise, Enterprise Plus) that bill slot capacity with autoscaling reservations; Enterprise and Enterprise Plus offer 1- or 3-year commitments. Reduce cost with partitioned and clustered tables, selecting only needed columns, maximum bytes billed limits, and `bq query --dry_run` estimates. Storage that has not been modified for 90 days is billed at a lower long-term rate automatically.

**Network** ingress is free. Egress between zones and between regions is charged, and internet egress costs more; the Standard Network Service Tier is cheaper than Premium but uses the public internet for more of the path and supports only regional load balancers. Place chatty components in the same region, use Cloud CDN for cacheable content, and account for egress in multicloud and hybrid designs.

## Migration

Google describes migration as assess, plan, deploy, and optimize. In the assessment, inventory applications, dependencies, performance, licensing, and compliance, then choose a disposition for each workload. The common "6 Rs" are:

| Strategy | Meaning | Typical Google Cloud target |
|---|---|---|
| Rehost (lift and shift) | Move as-is | Compute Engine via Migrate to Virtual Machines, VMware Engine |
| Replatform (lift and optimize) | Small changes to use managed services | Cloud SQL instead of self-managed MySQL, GKE for existing containers |
| Refactor or re-architect | Change the application to cloud-native patterns | Cloud Run, Pub/Sub, Spanner, Firestore |
| Repurchase | Replace with SaaS | Google Workspace, a vendor SaaS product |
| Retire | Switch off what is no longer needed | Nothing to migrate |
| Retain | Keep on premises for now | Hybrid connectivity to the rest |

Migration tools:

- **[Migration Center](https://docs.cloud.google.com/migration-center/docs/migration-center-overview)** discovers on-premises and other-cloud assets, collects utilization, and produces total cost of ownership and sizing reports.
- **[Migrate to Virtual Machines](https://docs.cloud.google.com/migrate/virtual-machines/docs)** replicates VMs from vSphere, AWS, Azure, or VMware Engine to Compute Engine, with test clones before cutover and minimal downtime.
- **[Database Migration Service](https://docs.cloud.google.com/database-migration/docs/overview)** performs continuous migrations using change data capture: MySQL, PostgreSQL, and SQL Server to Cloud SQL, PostgreSQL to AlloyDB, and Oracle or SQL Server to Cloud SQL for PostgreSQL or AlloyDB with schema conversion.
- **[Storage Transfer Service](https://docs.cloud.google.com/storage-transfer/docs/overview)** copies data from Amazon S3, Azure Blob Storage, HTTP sources, other buckets, or on-premises file systems (through agents) into Cloud Storage, on a schedule and incrementally.
- **[Transfer Appliance](https://docs.cloud.google.com/transfer-appliance/docs/4.0/overview)** is a physical device shipped to your data center for large offline transfers when the network would take too long.
- `gcloud storage` handles smaller one-off copies; BigQuery Migration Service translates SQL from other warehouses.

Estimate online transfer time before choosing: 100 TB over a fully used 1 Gbps link takes about nine days (100 × 10^12 bytes × 8 bits ÷ 10^9 bits per second ≈ 800,000 seconds), and real links rarely run at full utilization. Plan IP ranges, Interconnect lead times, license mobility (bring your own license, or sole-tenant nodes when terms require dedicated hardware), and a tested rollback before the cutover.

## The Well-Architected Framework

The [Google Cloud Well-Architected Framework](https://docs.cloud.google.com/architecture/framework) groups recommendations into six pillars, plus cross-pillar perspectives such as AI and ML and financial services:

- **Operational excellence**: automate deployment and operations, observe services with SLOs, manage incidents, and improve continuously.
- **Security, privacy, and compliance**: secure by design, zero trust, least privilege, protect data, and meet regulatory requirements.
- **Reliability**: define reliability goals from user needs, remove single points of failure, design for graceful degradation, and test recovery.
- **Cost optimization**: align spend with business value, build cost awareness, optimize resource usage, and review continuously.
- **Performance optimization**: plan resource allocation, use elasticity, design modular systems, and monitor performance.
- **Sustainability**: choose low-carbon regions, use resources efficiently, and measure the carbon footprint of workloads.

## Answering case-study questions

Most questions can be solved with the same steps:

1. **Find the requirements.** Separate business requirements (cost reduction, time to market, global expansion, compliance) from technical ones (latency, availability, data volume, existing technologies).
2. **Find the constraints.** Phrases such as "minimal operational overhead", "without code changes", "existing Spark jobs", "must remain in the EU", "on-premises for two more years", or "limited budget" eliminate most options.
3. **Choose the simplest managed service that meets them.** Prefer managed and serverless services over self-managed VMs, built-in features over custom code, and Google-recommended practices over workarounds.
4. **Check the answer against the whole question.** A technically correct option that ignores a stated constraint, adds unneeded components, or violates least privilege is wrong.

| Phrase in the question | Usually points to |
|---|---|
| Global users, relational, strong consistency, horizontal scale | Spanner |
| Lift and shift VMs quickly with minimal changes | Migrate to Virtual Machines to Compute Engine |
| Existing Hadoop or Spark jobs | Managed Service for Apache Spark (Dataproc) |
| New streaming pipeline with autoscaling | Pub/Sub and Dataflow |
| Petabyte-scale SQL analytics | BigQuery |
| High-throughput time series or IoT writes | Bigtable |
| Stateless container, scale to zero, no cluster management | Cloud Run |
| Prevent data exfiltration from managed services | VPC Service Controls |
| External CI or another cloud must call Google APIs without keys | Workload Identity Federation |
| Central network team, many application projects | Shared VPC |
| Private, high-bandwidth link to on-premises | Dedicated or Partner Interconnect |
| Protect a public web application from OWASP attacks and DDoS | Cloud Armor on an external Application Load Balancer |
| Keys must be controlled, rotated, or revoked by the customer | CMEK in Cloud KMS |
| Retain audit logs for years, tamper-resistant | Aggregated sink to a locked Cloud Storage bucket |

Common traps are basic roles, service account keys, choosing a self-managed product when a managed one fits, choosing a global service when the requirement is regional residency, and adding services that solve a problem the question does not have. Practise with the [official sample questions](https://cloud.google.com/learn/certification/cloud-architect) and the [Architecture Center](https://docs.cloud.google.com/architecture) reference architectures.

References: [exam page and guide](https://cloud.google.com/learn/certification/cloud-architect), [Well-Architected Framework](https://docs.cloud.google.com/architecture/framework), [resource hierarchy](https://docs.cloud.google.com/resource-manager/docs/cloud-platform-resource-hierarchy), [choose a load balancer](https://docs.cloud.google.com/load-balancing/docs/choosing-load-balancer), [disaster recovery planning guide](https://docs.cloud.google.com/architecture/dr-scenarios-planning-guide), and [migration to Google Cloud](https://docs.cloud.google.com/architecture/migration-to-gcp-getting-started).
