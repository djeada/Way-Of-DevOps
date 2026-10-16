# Database operations

A database needs controlled access, predictable changes, useful performance signals, and a tested recovery process. Begin with the application's data and availability requirements, then choose the engine and operating model.

## Choose storage for the workload

Relational databases such as PostgreSQL support structured relationships, constraints, and transactions. Key-value and document databases suit different access patterns and have their own consistency and query models. Learn the specific guarantees rather than treating all NoSQL systems as interchangeable.

Redis is commonly used as a cache or fast data store. Snowflake and BigQuery are analytical warehouses, which serve different workloads from a typical transactional application database. Decide from query patterns, data size, consistency, recovery, and operating cost.

## Access and protection

Keep the database reachable only by the clients that need it. Use network controls and authenticated connections; changing a default port or username does not replace either. Use separate identities for applications, administrators, migrations, and backups with the privileges each needs.

Use TLS with certificate verification where supported, including private networks. Protect storage and backup encryption keys, keep credentials in a secret store, and rotate or replace them through a tested process. Avoid using a master or superuser account for routine application work.

Patch the database and its host or managed service configuration on a planned schedule. Test compatibility before a major engine upgrade and document maintenance behavior and ownership.

## Performance and capacity

Monitor query latency, errors, active connections, connection-pool saturation, CPU, memory, disk space, IOPS, and replication lag. Review slow queries and execution plans before assuming the solution is a larger instance.

Indexes can speed reads while increasing storage and write cost. Transactions, locks, unbounded queries, and missing limits can affect other users. Test with representative data volumes and access patterns rather than only an empty development database.

A cache can reduce repeated work, but needs an expiry or invalidation policy and a plan for cache failure. Treat its data as disposable only when the application can reconstruct it.

## Migrations and releases

Version schema migrations alongside application changes and run them through a controlled release process. Coordinate concurrent deployers so the same migration is not applied twice. Test lock duration, runtime, and data impact on representative data.

Use an expand-and-contract approach when old and new application versions must coexist. For example, add a compatible field, deploy code that can use it, backfill safely, switch reads, and remove the old field only after older versions no longer depend on it.

Write a recovery strategy for each risky change. A down migration can be useful when it is safe and tested, but dropping a column or transforming data may be irreversible. Fixing forward or restoring data may be necessary. Do not assume every migration has a lossless inverse.

## Availability and recovery

Replication across failure domains can reduce downtime, but replicas can also copy accidental deletion or corruption. High availability and backups solve different problems.

Set recovery time and data-loss objectives, retain protected backup copies, and test restoring the application against restored data. Use immutable or write-protected copies when justified by the threat model and retention requirements. Verify who can change retention or delete copies; storage protection modes differ.

Export operational and audit logs with restricted access and appropriate retention. SQL and query logs can contain personal data, tokens, or confidential values, so collect only what is needed and redact where possible.

Continue with [backup and recovery](backup_and_recovery.md) and [security and secrets](security_and_secrets.md).
