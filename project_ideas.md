# Project ideas

Build one small application around a topic you understand: books, sports results, a game collection, or a personal inventory. Use synthetic or public data and add operational capabilities in stages. Each stage should leave you with something you can demonstrate and explain.

## 1. Run it locally

Create a web interface or HTTP API and store its data in a database. Add a few tests for important behavior and document how to start the application from a clean checkout. Use Compose if a repeatable local environment helps.

Show that the application can create and retrieve data, handle invalid input, and recover after a restart. Add a cache only after identifying a useful workload for it; explain how cached data expires or becomes invalid.

## 2. Automate verification and delivery

Run the same checks locally and in CI. Produce a versioned artifact, deploy it to a test environment, and verify a user journey after deployment. Record the source revision and artifact identity.

Demonstrate a failed check that prevents promotion, then a successful change. Keep the previous artifact available and explain when it is safe to roll back.

## 3. Reproduce the infrastructure

Choose a VM or a managed application service. Declare the infrastructure with an appropriate IaC tool and use configuration management where needed. Add a domain and TLS when the application has an intended public entry point.

Keep credentials out of Git, give the application limited access to its dependencies, and restrict database reachability. Show that a second learning environment can be created from the same definitions with separate data and configuration.

## 4. Operate and recover

Collect useful logs and metrics, define a simple service objective, and add an actionable alert. Back up the database and any user files, then restore them into a separate environment.

Simulate a dependency failure or a bad application release. Record how you detected it, mitigated it, and verified recovery. Measure the restore time and identify any unrecovered data.

## 5. Extend one capability

Choose an extension that answers a real question: a canary release, a GitOps controller, a queued background job, or orchestration across several hosts. Compare its operating cost and complexity with the simpler version. Kubernetes and multi-region deployment are optional extensions.

Keep a short runbook, an architecture sketch, and evidence for each milestone. For cloud experiments, track spending and delete unused compute, storage, snapshots, load balancers, and other billable resources when finished. Retain only the artifacts and data you deliberately need.

Use the [notes index](notes/README.md) for explanations and the [existing lab courses](labs/README.md) for focused practice.
