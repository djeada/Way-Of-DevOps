# Google Cloud Architect Foundations Quiz

Notes: [Google Cloud architecture for the Professional Cloud Architect exam](../notes/gcp_cloud_architecture.md), [Security and secrets](../notes/security_and_secrets.md), [Cloud fundamentals](../notes/cloud.md)

Check your understanding of the resource hierarchy, organization policies, IAM, workload identity, encryption, perimeters and audit logging on Google Cloud.

#### Q. A company must ensure that no resources are created outside the EU anywhere in its organization, regardless of who creates them. What should you do?

* [x] Set the resource locations organization policy on the organization node
* [ ] Grant project creators a custom IAM role that omits permissions for non-EU regions
* [ ] Create a Cloud Monitoring alert that fires when a resource appears outside the EU
* [ ] Add an IAM deny policy that blocks `compute.instances.create` for every principal

> **Explanation:** The `gcp.resourceLocations` constraint restricts where resources can be created for everyone below the node it is set on. IAM permissions cannot express a location, and an alert only detects the problem after the fact.

#### Q. A security team grants `roles/storage.admin` to a group on a folder. The owner of one project in that folder wants the group to have no Storage access in their project. What is true?

* [ ] Removing the binding from the project's allow policy overrides the folder grant
* [x] An inherited grant cannot be removed below the folder; use a deny policy
* [ ] Inherited bindings apply only to projects created after the folder grant was made
* [ ] Project-level allow policies always take precedence over folder-level allow policies

> **Explanation:** Allow policies are additive: effective access is the union of bindings on the resource and all its ancestors. Excluding a lower level requires a deny policy, a narrower folder grant, or moving the project.

#### Q. A central security team wants to apply stricter organization policies to every production project, including production projects created in the future, with the least ongoing effort. What should you do?

* [x] Put production projects in production folders and set the policies there
* [ ] Set the policies on each production project as part of its creation checklist
* [ ] Keep all projects in one folder and add a label that marks production projects
* [ ] Create a second organization that contains only the production projects

> **Explanation:** Policies set on a folder are inherited by every current and future project below it. Labels are metadata for cost and filtering and cannot scope policies; a second organization adds identity and administration overhead.

#### Q. Your organization must prevent anyone from granting IAM roles to personal Gmail accounts or to identities from other companies. Which control meets this requirement?

* [x] The domain restricted sharing organization policy, `iam.allowedPolicyMemberDomains`
* [ ] A VPC Service Controls perimeter that contains every project in the organization
* [ ] An IAM condition on each existing binding that checks the principal's email suffix
* [ ] Workforce Identity Federation configured with the corporate identity provider

> **Explanation:** Domain restricted sharing limits IAM grants to principals from approved Cloud Identity or Workspace customers. Conditions on existing bindings do not stop new grants, and VPC Service Controls protects API access to data, not who appears in allow policies.

#### Q. What is the main difference between an organization policy and an IAM allow policy?

* [x] Organization policies limit allowed configurations; allow policies grant permissions
* [ ] An organization policy grants roles to groups; an allow policy grants roles to individual users
* [ ] An organization policy applies only at the organization node; allow policies are inherited
* [ ] An organization policy is evaluated only for requests made by service accounts

> **Explanation:** IAM answers who may call an API on a resource, while organization policies constrain what configurations are allowed anywhere below a node, for every principal. Both are inherited down the hierarchy.

#### Q. Several teams share 200 projects, and finance needs monthly cost broken down by team and application. What should you do?

* [ ] Add network tags to each VM and filter the Billing reports by network tag
* [x] Label resources with `team` and `app` and analyze the billing export in BigQuery
* [ ] Create one billing account per team and link each shared project to every team's account
* [ ] Grant each team a custom role and report costs from Policy Analyzer results

> **Explanation:** Labels are carried into billing export data, so costs can be grouped by any label in BigQuery. A project links to only one billing account, and network tags and IAM data are not part of cost reporting.

#### Q. You want a group to manage only the Compute Engine instances that are bound to the Resource Manager tag `env=dev`. What should you do?

* [x] Grant the role with an IAM condition that checks the resource's tag
* [ ] Add a network tag `dev` to the VMs and name it in the role binding
* [ ] Add a label `env=dev` to the VMs and reference it in the role binding
* [ ] Create a custom role whose permission list includes the tag value

> **Explanation:** Resource Manager tags can be referenced in IAM conditions and are inherited. Labels and network tags are unrelated mechanisms that IAM conditions cannot use for this purpose, and roles contain permissions, not resource selectors.

#### Q. Developers hold the basic Editor role in production projects. You must move to Google-recommended practice with minimal disruption to their work. What should you do?

* [ ] Grant Owner in a separate break-glass project and remove all production access
* [ ] Keep Editor but enable Data Access audit logs to record what developers change
* [x] Replace Editor with narrow predefined roles per group, guided by IAM recommender
* [ ] Create one custom role with every Editor permission except the IAM permissions

> **Explanation:** Basic roles bundle thousands of permissions across all services. Predefined roles chosen from actual usage, which IAM recommender reports, keep needed access while removing the rest. A copy of Editor keeps almost all of the excess.

#### Q. A support team must be able to view, stop, start and reset VM instances but must never delete them. No predefined role matches exactly. What should you do?

* [x] Create a custom role with only the needed permissions for the group
* [ ] Grant `roles/compute.instanceAdmin.v1` and alert on deletions in Cloud Monitoring
* [ ] Grant the basic Viewer role and let the team impersonate the default service account
* [ ] Grant `roles/compute.admin` with an IAM condition that expires after 30 days

> **Explanation:** A custom role is the right tool when no predefined role is narrow enough; the team then owns its maintenance. Instance Admin includes delete, and an alert only reports a deletion after it happens.

#### Q. At which levels of the resource hierarchy can you create IAM custom roles?

* [ ] The organization, any folder, or any project
* [x] The organization or a project
* [ ] Only individual projects
* [ ] Any resource that has an allow policy

> **Explanation:** Custom roles are defined at the organization level, for use anywhere in it, or at the project level, for use only in that project. Folders cannot hold custom role definitions.

#### Q. An external auditor needs read access to a BigQuery dataset until the audit ends on a known date. Which approach needs the least administrative follow-up?

* [ ] Grant the role and set a calendar reminder to remove the binding
* [ ] Create a service account key that the auditor uses until the end date
* [x] Grant the role with an IAM condition that ends on that date
* [ ] Add the auditor to a group that is deleted when the audit closes

> **Explanation:** A time-based IAM condition makes the binding stop granting access automatically. Reminders and group deletion depend on someone acting, and a service account key is a long-lived secret that should not be handed to a person.

#### Q. Nobody except the `security-admins` group may delete projects in the production folder, whatever roles are granted there now or in the future. What should you do?

* [ ] Grant `security-admins` Owner on the folder so their grant overrides other grants
* [x] Attach a deny policy on the folder with an exception for that group
* [ ] Set an organization policy that disables the Resource Manager API in production
* [ ] Rely on Admin Activity audit logs to identify anyone who deletes a project

> **Explanation:** Deny policies are checked before allow policies and block the listed permissions regardless of current or future grants, with exceptions for named principals. Allow grants never override each other, and audit logs only record the deletion.

#### Q. Service accounts in your analytics project must only ever be able to access resources in your own organization, even if someone in another organization grants them a role. Which control fits?

* [ ] Domain restricted sharing set on your organization node
* [ ] A deny policy attached to every project in your organization
* [x] A principal access boundary policy for those service accounts
* [ ] A VPC firewall rule that blocks egress from analytics VMs

> **Explanation:** Principal access boundary policies attach to sets of principals and limit which resources they are eligible to access, wherever the grant is made. Domain restricted sharing controls who can be granted roles in your organization, not where your principals can go.

#### Q. An application on Compute Engine must write objects to one Cloud Storage bucket. What is the recommended way to give it credentials?

* [x] Attach a user-managed service account with a narrow role on the bucket
* [ ] Create a service account key and copy it onto the VM's boot disk at deployment
* [ ] Use the default Compute Engine service account with its project Editor role
* [ ] Store a developer's user credentials in Secret Manager and read them at startup

> **Explanation:** An attached service account gets short-lived tokens from the metadata server, so there is no secret to leak or rotate. The default service account historically holds Editor, which violates least privilege.

#### Q. A GitHub Actions workflow deploys to Cloud Run, and security policy forbids long-lived credentials outside Google Cloud. What should you do?

* [ ] Store a service account key as an encrypted GitHub secret and rotate it every 90 days
* [ ] Grant the Cloud Run Admin role to the GitHub organization's domain principal
* [ ] Use Workforce Identity Federation to map each developer's GitHub login to Google
* [x] Use Workload Identity Federation with GitHub's OIDC tokens

> **Explanation:** Workload Identity Federation exchanges the workflow's short-lived OIDC token for a short-lived Google token, so no key exists. Workforce Identity Federation is for human users, and a rotated key is still a long-lived secret.

#### Q. Pods in a GKE cluster need to publish to one Pub/Sub topic, and other workloads on the same nodes must not get that permission. What should you do?

* [ ] Mount a service account key from a Kubernetes Secret into the Pods
* [x] Use Workload Identity Federation for GKE for those Pods
* [ ] Grant the Pub/Sub Publisher role to the node pool's service account
* [ ] Use IAP TCP forwarding from the Pods to the Pub/Sub API endpoint

> **Explanation:** Workload Identity Federation for GKE gives each Kubernetes service account its own IAM identity without keys. Granting the role to the node service account would give it to every Pod on those nodes.

#### Q. An engineer has Cloud Run Developer permissions and must deploy a service that runs as the `orders` service account. Which additional grant does the engineer need?

* [x] Service Account User on the `orders` service account
* [ ] Service Account Key Admin on the `orders` service account
* [ ] Cloud Run Invoker on the service being deployed
* [ ] Security Reviewer on the project that holds the service

> **Explanation:** Attaching a service account to a resource requires `iam.serviceAccounts.actAs`, granted by the Service Account User role. Without this check, anyone able to deploy could act with any service account's permissions.

#### Q. Administrators occasionally need elevated permissions for maintenance tasks. Security wants that access to be short-lived and attributable to the individual. What should you do?

* [x] Let them impersonate a privileged service account when needed
* [ ] Give each administrator a downloaded key for a privileged service account
* [ ] Grant each administrator the Owner role permanently on all production projects
* [ ] Share one administrative user whose password is kept in Secret Manager

> **Explanation:** Impersonation issues short-lived tokens and audit logs record both the administrator and the service account. Keys are long-lived, permanent Owner breaks least privilege, and a shared account loses individual accountability.

#### Q. A company manages employees in Active Directory and wants them to sign in to Google Cloud with their existing passwords while keeping users and groups current in Cloud Identity. What should you do?

* [x] Sync with Google Cloud Directory Sync and use SAML single sign-on
* [ ] Create Cloud Identity accounts by hand and ask employees to reuse their current passwords
* [ ] Create a service account per employee and distribute the keys through Group Policy
* [ ] Enable Identity-Aware Proxy in front of the Active Directory domain controllers

> **Explanation:** Directory Sync copies users and groups from Active Directory into Cloud Identity, and SAML SSO keeps authentication in the existing identity provider. Service accounts are for workloads, not people.

#### Q. Operators need SSH access to Linux VMs that have no external IP addresses, and the company does not want to run a bastion host. What should you do?

* [ ] Assign ephemeral external IP addresses to the VMs during maintenance windows
* [ ] Configure Cloud NAT so that inbound SSH connections are forwarded to the VMs
* [x] Use IAP TCP forwarding and control who may connect through IAM
* [ ] Enable Private Google Access on the subnet that contains the VMs

> **Explanation:** IAP TCP forwarding tunnels SSH through Google after checking identity, so VMs need no public address. Cloud NAT only handles outbound connections, and Private Google Access is for reaching Google APIs.

#### Q. A regulation requires that the company can rotate, disable and destroy the keys protecting its BigQuery and Cloud Storage data itself. What should you use?

* [ ] Default encryption with Google-owned and Google-managed keys
* [x] Customer-managed encryption keys in Cloud KMS
* [ ] Customer-supplied encryption keys sent with each request
* [ ] Secrets in Secret Manager that hold the data encryption keys

> **Explanation:** CMEK keeps the key in Cloud KMS under your control, and disabling it makes protected data unreadable. Customer-supplied keys work only with Cloud Storage and Compute Engine, not BigQuery.

#### Q. A bank's regulator requires that encryption keys for its Google Cloud data are held in a key manager operated outside Google's infrastructure. Which option meets this?

* [ ] Cloud HSM keys in a dedicated project
* [x] Cloud External Key Manager
* [ ] Cloud KMS Autokey
* [ ] Secret Manager with CMEK enabled

> **Explanation:** Cloud EKM uses keys stored in a supported external key manager, so they never reside in Google. Cloud HSM keys are hardware-protected but still inside Google Cloud, and Autokey only automates creating Cloud KMS keys.

#### Q. A security team must administer encryption keys, while an application's service account must only encrypt and decrypt with one key. How should you grant access?

* [x] Security team: Cloud KMS Admin; service account: Encrypter/Decrypter on the key
* [ ] Security team and service account: Cloud KMS Admin on the project that holds the key
* [ ] Service account: Owner on the key project so that it can also rotate the key
* [ ] Security team: CryptoKey Encrypter/Decrypter; service account: Cloud KMS Admin

> **Explanation:** Splitting key administration from key use is separation of duties. The application never needs to change, rotate or destroy keys, and administrators do not need to use them to read data.

#### Q. A Cloud Run service needs a database password at runtime. What is the recommended way to provide it?

* [ ] Bake the password into the container image as an environment variable
* [ ] Commit an encrypted file to Git with its decryption key in the same repository
* [x] Store it in Secret Manager and grant the service's account access to that secret
* [ ] Save the password as a label on the Cloud Run service for easy rotation

> **Explanation:** Secret Manager provides versioned secrets with per-secret IAM and audit logging, and the service reads it with its own identity. Images, Git and labels expose the value to anyone who can read them.

#### Q. A healthcare company worries that an insider with valid credentials could copy BigQuery data into a bucket in a personal project. Which control mitigates this?

* [x] A VPC Service Controls perimeter around the projects that hold the data
* [ ] Removing external IP addresses from all VMs in the data projects
* [ ] VPC firewall rules that deny egress traffic to the BigQuery API
* [ ] Data Access audit logs enabled for BigQuery in the data projects

> **Explanation:** A service perimeter blocks Google API access that crosses its boundary, even with valid credentials, so data cannot be copied to a project outside it. Firewall rules do not govern API calls between projects, and logs only record the copy.

#### Q. You are adding VPC Service Controls to existing production projects and fear blocking legitimate traffic. What should you do first?

* [x] Run the perimeter in dry-run mode and review the reported violations
* [ ] Enforce the perimeter late on a Friday when traffic is at its lowest
* [ ] Create an empty perimeter and add the production projects one by one
* [ ] Start with an IAM deny policy and convert it into a perimeter later

> **Explanation:** Dry-run mode logs requests that would be denied without blocking them, so you can add access levels or ingress and egress rules before enforcement. Deny policies and perimeters are different mechanisms.

#### Q. Only container images built and signed by the company's CI pipeline may run on production GKE clusters. What should you implement?

* [ ] Restrict read access in Artifact Registry to the node service account
* [x] Binary Authorization with a policy requiring the pipeline's attestation
* [ ] Security Command Center rules that delete unsigned Pods after they start
* [ ] A Cloud Armor security policy that blocks requests from unsigned images

> **Explanation:** Binary Authorization enforces policy at deploy time on GKE and Cloud Run, admitting only images with the required attestations. Registry permissions do not prove how an image was built, and Cloud Armor filters HTTP requests.

#### Q. Which Cloud Audit Logs type is disabled by default for most services and must be enabled to record reads of Cloud Storage object data?

* [x] Data Access audit logs
* [ ] Admin Activity audit logs
* [ ] System Event audit logs
* [ ] Policy Denied audit logs

> **Explanation:** Data Access logs record reads of configuration and reads or writes of user data; they are off by default except for BigQuery because they can be large. Admin Activity and System Event logs are always on.

#### Q. Audit logs from every project must be kept for seven years in a tamper-resistant form. What should you do?

* [ ] Raise the retention of each project's `_Required` log bucket to seven years
* [ ] Export the logs weekly with a script on a Compute Engine VM
* [x] Use an organization aggregated sink to a bucket with a locked retention policy
* [ ] Rely on Admin Activity logs, which Google keeps for the lifetime of the project

> **Explanation:** An aggregated sink with child projects included captures every project, including future ones, and Bucket Lock prevents deletion before the retention period ends. The `_Required` bucket's 400-day retention cannot be changed.

#### Q. A government contractor must run workloads under a regulatory control package that enforces data location, allowed services and personnel access restrictions. What should you use?

* [ ] A US region with the default project and folder settings
* [ ] Access Transparency enabled for the whole organization
* [x] An Assured Workloads folder with the matching control package
* [ ] Sole-tenant nodes for every Compute Engine workload

> **Explanation:** Assured Workloads applies a control package, such as FedRAMP or CJIS controls, to a folder, including location restrictions and personnel controls. Access Transparency only logs Google personnel actions, and sole tenancy isolates hardware.

#### Q. A bank wants Google support staff to be unable to access its content until a bank employee explicitly approves each request. Which feature provides this?

* [x] Access Approval
* [ ] Access Transparency
* [ ] Data Access audit logs
* [ ] Security Command Center

> **Explanation:** Access Approval holds Google personnel access until you approve it. Access Transparency only records such access after it happens, and Data Access logs record your own principals' activity.

#### Q. Card numbers in customer support transcripts must be masked or tokenized before the transcripts are loaded into an analytics warehouse. What should you use?

* [ ] CMEK on the warehouse tables so that card numbers are encrypted at rest
* [ ] A VPC Service Controls perimeter around the warehouse project
* [x] Sensitive Data Protection inspection and de-identification in the pipeline
* [ ] Secret Manager entries that store each transcript separately

> **Explanation:** Sensitive Data Protection finds sensitive values and masks or tokenizes them before they reach the warehouse. CMEK and perimeters protect the stored data, but anyone allowed to query it would still see the card numbers.

#### Q. A security team wants one place to see misconfigurations such as public buckets and open firewall ports across all projects, with compliance reports against CIS benchmarks and minimal custom development. What should you do?

* [x] Activate Security Command Center at the organization level
* [ ] Export Cloud Asset Inventory to BigQuery and write audit queries
* [ ] Create log-based metrics for firewall changes in every project
* [ ] Grant the security team Policy Troubleshooter in every project

> **Explanation:** Security Command Center detects misconfigurations, vulnerabilities and threats across an organization and reports compliance against benchmarks such as CIS. Building the same from asset exports and queries is custom work to maintain.
