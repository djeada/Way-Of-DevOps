# Backup and recovery

A backup is useful when the service can be restored from it within the required time and with an acceptable amount of lost data. Define those requirements before choosing the schedule or storage.

## Set recovery objectives

Recovery point objective (RPO) describes the acceptable amount of data loss measured in time. Recovery time objective (RTO) describes how long restoration may take. For example, an RPO of 15 minutes and an RTO of one hour require both sufficiently recent recoverable data and a restore procedure that fits within an hour.

Include databases, user uploads, configuration, infrastructure definitions, and the keys or credentials needed for recovery. Assign an owner to each data source and document dependencies that determine restore order.

## Protect useful copies

Keep copies separate from the original failure domain and restrict who can delete or alter them. Use encryption, retention policies, and immutable or offline copies when needed. Monitor backup freshness and failures as well as the success of the backup job.

A replica can improve availability while copying accidental deletion. A VM snapshot can depend on the original storage. Neither automatically supplies an independent, recoverable history. Understand application consistency: a filesystem copy of live database files may not be a usable database backup.

Record which database logs, full backups, incremental backups, and encryption keys are required for a restore. Retain them for the same recovery window and verify the chosen mechanism's guarantees.

## Practice a restore

1. Select a recovery point and identify the necessary copies and keys.
2. Restore into a separate environment to avoid overwriting current data during investigation.
3. Validate the data and start a compatible application version.
4. Check important workflows, permissions, jobs, and external integrations.
5. Measure elapsed recovery time and the actual gap in recovered data.
6. Document the cutover procedure and clean up the test environment.

Keep destructive or externally visible background jobs disabled during a restore drill. For a real incident, coordinate writes and traffic during cutover so the restored service does not conflict with the old one.

## Recovery is different from rollback

Deploying a previous application artifact can undo a code change when data and configuration remain compatible. Point-in-time database recovery reconstructs data at an earlier time; later writes may be lost and need reconciliation.

For Amazon RDS DB instances, point-in-time recovery creates a new instance. Reconnecting the application, validating the result, and switching traffic are additional steps. Other engines and services have their own restore behavior.

Keep the procedure accessible even when the primary environment is unavailable. Repeat drills after changes to storage, authentication, encryption, or application schema.

Reference: [Amazon RDS point-in-time recovery](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PIT.html). Related: [database migrations](best_practices.md) and [incident response](observability.md).
