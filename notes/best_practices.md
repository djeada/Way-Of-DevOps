* Don't use the default port.
* Don't use admin as a username.
* Rotate your master user password regularly.
* Restrict users to least access privileges. That includes application credentials. Review access regularly.
* Never expose them to connections on the public web.
* Regular backups.
* Regularly test your recovery plan vs RTO and RPO.
* Regularly review metrics such as CPU, Memory, IOPS and network throughput. (right sizing).
* Automatically monitor the above metrics.
* Where possible, replicate across AZs.
* Backups should be WORM. No one should be able to delete them until a compliance lock expires (including root).
* Encrypted storage where possible.
* Require SSL (even in private subnets).
* Patch regularly.
* Export logs. Treat them as confidential if they contain raw query data.
* USE DATABASE MIGRATIONS. Don't have people (including yourself) keyboard cowboy-ing each release in the database executing manual SQL statements that are not within source control.
Make sure the DB migrations process is part of your normal release pipeline so that it is normalized. Make sure responsible parties define both UP and DOWN paths for each migration so you can roll back if you're not fixing forward when things explode.
