# Google Cloud Architect Data and Reliability Quiz

Notes: [Google Cloud architecture for the Professional Cloud Architect exam](../notes/gcp_cloud_architecture.md), [Backup and recovery](../notes/backup_and_recovery.md), [Observability and incidents](../notes/observability.md), [Database operations](../notes/best_practices.md)

Check your understanding of storage classes and options, database choice, data processing services and recovery designs on Google Cloud.

#### Q. Database backups are written to Cloud Storage daily, kept for at least two months, and restored about once a month for testing. Which storage class is the most cost-effective?

* [ ] Standard
* [x] Nearline
* [ ] Coldline
* [ ] Archive

> **Explanation:** Nearline suits data read about once a month and has a 30-day minimum storage duration. Coldline and Archive store data more cheaply but charge more for each retrieval and have longer minimum durations.

#### Q. Records must be retained for ten years for regulatory reasons and will almost never be read. Which storage class should you choose?

* [ ] Nearline
* [ ] Coldline
* [x] Archive
* [ ] Standard

> **Explanation:** Archive has the lowest storage price, a 365-day minimum storage duration and the highest retrieval cost, which fits data accessed less than once a year. All classes keep millisecond access latency.

#### Q. A bucket holds millions of objects with unpredictable and changing access patterns, and the team does not want to write or maintain storage class transition rules. What should you do?

* [ ] Keep all objects in Standard to avoid retrieval charges
* [x] Enable Autoclass on the bucket
* [ ] Write a nightly job that rewrites cold objects to Archive
* [ ] Create a lifecycle rule that moves objects to Coldline after 30 days

> **Explanation:** Autoclass moves each object between storage classes based on its own access pattern. A fixed age-based lifecycle rule can move objects that are still read often into classes with retrieval charges.

#### Q. Log files must move to Coldline 90 days after creation and be deleted after five years, with no custom code. What should you configure?

* [x] Object Lifecycle Management rules on the bucket
* [ ] A Cloud Run job that rewrites old objects nightly
* [ ] A retention policy locked with Bucket Lock
* [ ] Object versioning with a version count limit

> **Explanation:** Lifecycle rules change storage class or delete objects based on conditions such as age. A retention policy prevents deletion before a period ends; it does not move or delete objects.

#### Q. An object stored in Coldline is deleted ten days after it was written. How is its storage billed?

* [ ] Only for the ten days the object existed
* [ ] For ten days at the Standard class price
* [x] As if it had been stored for the 90-day minimum
* [ ] Nothing, because deletions are not billed

> **Explanation:** Nearline, Coldline and Archive have minimum storage durations of 30, 90 and 365 days. Deleting or changing the class earlier incurs a charge for the remaining period.

#### Q. A bucket's data must stay in two specific EU regions, survive the loss of one region, and replicate between them as quickly as Cloud Storage allows. What should you create?

* [ ] A regional bucket with a daily copy job to another region
* [x] A dual-region bucket with turbo replication enabled
* [ ] A multi-region bucket in the US multi-region
* [ ] A regional bucket with object versioning enabled

> **Explanation:** A dual-region bucket stores data in two chosen regions, and turbo replication gives a faster replication target. A multi-region covers a large area rather than two specific regions, and the US one breaks residency.

#### Q. Financial records must not be deleted or modified for seven years, even by project owners. What should you configure?

* [ ] Object versioning with soft delete enabled
* [ ] Uniform bucket-level access with reader-only IAM roles
* [x] A retention policy on the bucket, locked with Bucket Lock
* [ ] CMEK on the bucket with key rotation every year

> **Explanation:** A locked retention policy enforces write-once-read-many behavior: objects cannot be deleted or replaced until they reach the retention period, and the lock cannot be removed. IAM can be changed by owners.

#### Q. A partner without a Google identity must download one large file from a private bucket for the next 24 hours. What should you do?

* [x] Generate a signed URL for the object that expires after 24 hours
* [ ] Grant `allUsers` the Storage Object Viewer role on the bucket for a day
* [ ] Create a service account key for the partner and revoke it the next day
* [ ] Copy the object to a public bucket and delete it after 24 hours

> **Explanation:** A signed URL grants time-limited access to one object without an identity or a policy change. Public access exposes the object to everyone, and a key handed to a partner is a long-lived secret.

#### Q. Users sometimes overwrite objects by mistake and need to restore the previous content of an object. Which bucket feature makes this possible?

* [x] Object versioning
* [ ] Autoclass
* [ ] Uniform bucket-level access
* [ ] Turbo replication

> **Explanation:** With object versioning, an overwritten or deleted object becomes a noncurrent version that you can restore. Autoclass changes storage classes, and turbo replication affects dual-region copy speed.

#### Q. A database VM on a machine series that supports Hyperdisk needs more IOPS, but its disk already has more capacity than required. What should you do?

* [ ] Resize the disk until its size-based performance is high enough
* [x] Raise the provisioned IOPS on its Hyperdisk volume
* [ ] Add a Local SSD and move the database files there
* [ ] Switch the disk to Persistent Disk Standard

> **Explanation:** Hyperdisk provisions capacity, IOPS and throughput separately, so performance can be raised without paying for unused space. Local SSD is ephemeral, which is unsuitable for primary database files.

#### Q. A batch job needs the lowest-latency scratch space possible for intermediate files that can be regenerated if lost. Which storage should you use?

* [ ] Hyperdisk Balanced High Availability
* [ ] Regional Persistent Disk
* [ ] Filestore
* [x] Local SSD

> **Explanation:** Local SSD is physically attached to the host and gives the highest performance, but its data does not survive certain VM events. That is acceptable for rebuildable scratch data and avoids paying for replication.

#### Q. A self-managed database on Compute Engine needs a block disk that is synchronously replicated to a second zone so that a zone failure loses no committed data. What should you use?

* [ ] A zonal disk with hourly snapshots
* [ ] Local SSD in a RAID configuration
* [x] Hyperdisk Balanced High Availability
* [ ] Hyperdisk Throughput

> **Explanation:** Hyperdisk Balanced High Availability, like regional Persistent Disk, writes synchronously to two zones, giving an RPO of zero for a zone outage. Snapshots only bound loss to the snapshot interval.

#### Q. Several VMs running a legacy application need a shared POSIX file system mounted over NFS. Which managed service fits?

* [ ] Cloud Storage with object versioning
* [x] Filestore
* [ ] Hyperdisk ML
* [ ] Bigtable

> **Explanation:** Filestore provides managed NFS file shares that many clients can mount. Hyperdisk ML attaches read-only to many instances, and Cloud Storage is an object store rather than a POSIX file system.

#### Q. A company is moving an on-premises MySQL database for a regional web application to Google Cloud with minimal changes and wants Google to handle backups, patching and failover. What should you choose?

* [x] Cloud SQL for MySQL
* [ ] Spanner regional instance
* [ ] Bigtable with the HBase API
* [ ] Firestore in Datastore mode

> **Explanation:** Cloud SQL is managed MySQL, PostgreSQL and SQL Server with backups, maintenance and high availability. Spanner and Bigtable would require schema and application changes, and Firestore is a document database.

#### Q. A global payments ledger needs relational transactions, strong consistency, horizontal scaling and writes accepted in several continents with the highest availability. Which option should you choose?

* [ ] Cloud SQL with cross-region read replicas
* [x] Spanner with a multi-region configuration
* [ ] Bigtable with replication across clusters
* [ ] AlloyDB with read pool instances

> **Explanation:** Spanner provides externally consistent transactions across regions and scales horizontally; multi-region configurations use the Enterprise Plus edition. Cloud SQL and AlloyDB have one writable primary, and Bigtable has no multi-row transactions.

#### Q. Millions of IoT sensors send readings every second. The application needs very high write throughput and low-latency lookups of a device's readings over a time range. Which database fits?

* [ ] Cloud SQL for PostgreSQL
* [ ] Firestore in Native mode
* [x] Bigtable
* [ ] Memorystore for Valkey

> **Explanation:** Bigtable is a wide-column store built for very high write throughput and fast reads by row key, which suits time series. Cloud SQL cannot scale writes this way, and Memorystore is an in-memory cache.

#### Q. A Bigtable table uses row keys that start with the event timestamp, and all writes land on one node. What should you change?

* [ ] Add more nodes to the cluster so that writes spread out
* [x] Put the device ID before the timestamp in the row key
* [ ] Add a secondary index on the timestamp column family
* [ ] Switch the table to a SQL interface that supports joins

> **Explanation:** Rows are sorted by key, so keys beginning with a timestamp send all new writes to the same tablet. Leading with a well-distributed value spreads load; more nodes do not help a hotspot.

#### Q. A mobile app needs a serverless database with real-time updates to clients and offline support on devices. Which service fits best?

* [ ] Cloud SQL for PostgreSQL
* [ ] BigQuery
* [ ] Bigtable
* [x] Firestore

> **Explanation:** Firestore is a serverless document database with real-time listeners and offline client support for mobile and web apps. BigQuery is for analytics, and Bigtable has no client synchronization features.

#### Q. A web application needs a managed store for user sessions with sub-millisecond reads, and sessions may be rebuilt if lost. Which service should you use?

* [ ] Cloud SQL for MySQL
* [x] Memorystore
* [ ] Filestore
* [ ] Spanner

> **Explanation:** Memorystore provides managed in-memory Valkey, Redis or Memcached, which suits caches and session stores. Disk-based databases add latency and cost for data that can be recreated.

#### Q. Analysts need standard SQL over several petabytes of event data without managing servers or clusters. Which service should you choose?

* [x] BigQuery
* [ ] Cloud SQL
* [ ] AlloyDB
* [ ] Bigtable

> **Explanation:** BigQuery is a serverless data warehouse that separates storage and compute for large-scale SQL analytics. The others are operational databases and either do not scale to petabytes or do not offer analytical SQL.

#### Q. A PostgreSQL application needs higher transactional performance than it gets today and also runs heavy analytical queries on the same data. The team wants to stay PostgreSQL-compatible. What should you recommend?

* [ ] Cloud SQL for MySQL with read replicas
* [ ] Bigtable with a PostgreSQL client library
* [x] AlloyDB for PostgreSQL
* [ ] Firestore with composite indexes

> **Explanation:** AlloyDB is PostgreSQL-compatible and adds a columnar engine and read pools, which help mixed transactional and analytical workloads. The other options change the engine or data model.

#### Q. A Cloud SQL instance must fail over automatically if its zone fails, with no loss of committed transactions. What should you configure?

* [ ] A read replica in another zone of the same region
* [x] High availability with a standby in another zone
* [ ] Automated daily backups with point-in-time recovery
* [ ] A cross-region read replica promoted by a script

> **Explanation:** Cloud SQL high availability replicates synchronously to a standby in another zone and fails over automatically. Read replicas are asynchronous and need promotion, and backups require a restore.

#### Q. A Cloud SQL database must be recoverable in another region within an hour if its primary region fails, losing at most a few minutes of data. What should you add?

* [x] A cross-region read replica that can be promoted
* [ ] A second high availability standby in the same region
* [ ] Daily exports of the database to a regional bucket
* [ ] A larger machine type for the primary instance

> **Explanation:** A cross-region replica receives changes asynchronously, so promoting it loses only the replication lag. High availability protects against zone failure only, and daily exports allow up to a day of data loss.

#### Q. Many producers emit events in bursts, and several independent consumers must process them at their own pace without the producers waiting. Which service should sit between them?

* [ ] Cloud Storage with object notifications
* [x] Pub/Sub topics with a subscription per consumer
* [ ] Memorystore lists polled by each consumer
* [ ] A Cloud SQL table used as a queue

> **Explanation:** Pub/Sub decouples producers from consumers, buffers bursts, and delivers each message to every subscription. Databases and caches used as queues need custom locking and scale poorly.

#### Q. A new pipeline must read events from Pub/Sub, aggregate them in time windows and write results to BigQuery, with autoscaling and no cluster management. What should you use?

* [ ] Managed Service for Apache Spark clusters
* [ ] A Compute Engine MIG running custom consumers
* [x] Dataflow running an Apache Beam pipeline
* [ ] Cloud Run functions writing each event

> **Explanation:** Dataflow is serverless, autoscales, and supports windowing and exactly-once processing for streaming pipelines. Spark clusters fit existing Spark code, and per-event functions cannot aggregate over windows.

#### Q. A company has hundreds of existing Spark jobs on an on-premises Hadoop cluster and wants to move them quickly with minimal code changes. What should you recommend?

* [x] Managed Service for Apache Spark (formerly Dataproc)
* [ ] Rewrite every job as an Apache Beam pipeline on Dataflow
* [ ] Run the jobs as Cloud Run jobs with Spark in local mode
* [ ] Load the input into BigQuery and replace each job with SQL

> **Explanation:** Managed Service for Apache Spark runs existing Spark and Hadoop jobs with few changes, ideally on short-lived clusters or serverless batches reading from Cloud Storage. Rewriting for Dataflow or BigQuery is a larger project.

#### Q. A data team runs multi-step workflows with dependencies across BigQuery, Dataflow and external systems, and already writes Airflow DAGs. Which managed service should orchestrate them?

* [ ] Pub/Sub with push subscriptions
* [ ] Dataflow with Flex Templates
* [x] Managed Service for Apache Airflow
* [ ] Cloud Run functions on a schedule

> **Explanation:** Managed Service for Apache Airflow, formerly Cloud Composer, runs Airflow DAGs that orchestrate tasks across services. Dataflow processes data within one pipeline, and Pub/Sub carries messages but does not manage dependencies.

#### Q. Changes in an operational MySQL database must be replicated continuously into BigQuery for near-real-time analytics, without writing custom code. What should you use?

* [ ] Storage Transfer Service
* [x] Datastream
* [ ] Transfer Appliance
* [ ] Cloud Run jobs

> **Explanation:** Datastream reads database change logs and replicates changes into BigQuery or Cloud Storage. Storage Transfer Service and Transfer Appliance copy files and objects, not database changes.

#### Q. An insurer wants to extract text from scanned claim forms quickly, and the team has no machine learning experience. What should you recommend first?

* [x] A pre-trained Google AI API for text detection in images
* [ ] A custom model trained from scratch on GPUs
* [ ] A Bigtable table that stores the scanned images
* [ ] A Dataflow pipeline with handwritten parsing rules

> **Explanation:** Pre-trained APIs such as Vision solve common tasks without training a model. Custom training needs labeled data and ML skills and is justified only when hosted models or APIs do not meet the requirement.

#### Q. A generative AI assistant must screen user prompts and model responses for prompt injection attempts and sensitive data. Which Google Cloud service is designed for this?

* [ ] Cloud Armor
* [x] Model Armor
* [ ] Binary Authorization
* [ ] VPC Service Controls

> **Explanation:** Model Armor inspects prompts and responses of AI applications for threats such as prompt injection and for sensitive data. Cloud Armor filters HTTP traffic at load balancers and does not understand model inputs.

#### Q. An internal reporting system has an RTO of 24 hours and an RPO of one day, and the business wants the lowest disaster recovery cost. Which pattern fits?

* [x] Backup and restore with infrastructure recreated from code
* [ ] Warm standby with a scaled-down copy in another region
* [ ] Active-active deployment across two regions
* [ ] Hot standby with synchronous replication

> **Explanation:** Generous RTO and RPO allow cold recovery: keep backups in another region and rebuild infrastructure after a disaster. Standby or active-active designs pay for running capacity the objectives do not require.

#### Q. An order service needs an RTO of 30 minutes and an RPO of a few minutes after a regional outage, at moderate cost. Which pattern fits best?

* [ ] Daily backups restored into a new region
* [x] Warm standby with replicated data in another region
* [ ] Active-active serving from several regions
* [ ] A single regional deployment with zonal redundancy

> **Explanation:** A warm standby keeps a scaled-down environment and replicated data ready, so recovery means promoting and scaling up. Restoring backups takes too long, and active-active costs more than the objectives require.

#### Q. A request passes through three components in series, each with 99.9% availability and independent failures. What is the approximate availability of the request path?

* [ ] 99.97%
* [ ] 99.9%
* [x] 99.7%
* [ ] 99.99%

> **Explanation:** Serial availabilities multiply: $0.999 \times 0.999 \times 0.999 \approx 0.997$. Each dependency in a chain reduces overall availability, which is why redundancy matters.

#### Q. An application runs on a zonal managed instance group behind a load balancer. It must survive a zone outage with the smallest change. What should you do?

* [x] Replace it with a regional managed instance group
* [ ] Add a larger machine type to the instance template
* [ ] Take hourly snapshots of each VM's boot disk
* [ ] Move the group to a multi-region bucket backend

> **Explanation:** A regional MIG spreads identical VMs across zones in a region, and the load balancer sends traffic to healthy ones. Snapshots help restore data but do not keep the service running during an outage.

#### Q. Backups must stay protected even if an attacker compromises an administrator account in the workload's project. Which approach fits best?

* [ ] Store snapshots in the same project with a deletion alert
* [x] Backup and DR Service vaults in a separate project
* [ ] Keep backups on Local SSD attached to a dedicated VM
* [ ] Rely on object versioning in the workload's own bucket

> **Explanation:** Backup vaults keep copies immutable and protected from deletion or modification during their retention, and a separate project limits the reach of a compromised account. Backups in the same project can be deleted by its administrators.
