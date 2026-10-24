# DevOps Delivery Quiz

Notes: [CI/CD](../notes/ci_cd.md), [Continuous integration](../notes/continuous_integration.md), [GitHub Actions](../notes/github_actions.md), [Canary releases](../notes/canary_release.md), [GitOps](../notes/git_ops.md), [How a full-stack application reaches the cloud](../notes/full_stack_app_with_cloud.md)

Check your understanding of pipelines, release strategies, workflow security, canaries, GitOps and the path from commit to customer.

#### Q. Every change that passes the required checks on `main` goes to production automatically, with no human approval. Which practice is this?

* [ ] Continuous integration
* [ ] Continuous delivery
* [x] Continuous deployment
* [ ] Trunk-based branching

> **Explanation:** Continuous deployment releases every passing change automatically. Continuous delivery also produces a deployable artifact for every passing change, but production deployment can wait for an explicit decision or approval.

#### Q. A team's pipeline builds a deployable image for every merge, deploys it to staging, and waits for a release manager to approve production. Which practice does this describe?

* [x] Continuous delivery
* [ ] Continuous deployment
* [ ] Blue/green deployment
* [ ] Feature flagging

> **Explanation:** In continuous delivery, a passing change produces a deployable artifact, and the production deployment can require an explicit approval. Continuous deployment would release it automatically.

#### Q. Staging tested an image built from commit `a1b2c3`. The production job rebuilds a new image from the same commit and deploys it. What is the main problem?

* [ ] Production deployments must always use the `latest` tag
* [x] The rebuilt image may differ from the one that was tested
* [ ] Rebuilding is fine as long as the source commit matches
* [ ] Production must be built from a separate release branch

> **Explanation:** Rebuilds can pick up different dependencies, base images or build tools. Build once, record the artifact digest and promote that same artifact between environments, keeping environment configuration separate.

#### Q. A release record says only `myapp:latest`. Why is this insufficient for reproducing what was deployed?

* [ ] The `latest` tag cannot be pulled by Kubernetes nodes
* [ ] Registries delete images tagged `latest` after a week
* [x] A tag can be moved, so it does not identify fixed content
* [ ] The `latest` tag always points to the oldest image pushed

> **Explanation:** Tags are mutable and can be reassigned to new images. Record the source revision and the immutable artifact digest so the release can be identified and reproduced exactly.

#### Q. A deployment job is triggered both by the merged pull request event and by the resulting push to `main`. Each merge deploys twice. What should the team do?

* [ ] Add a retry so the second deployment overwrites the first
* [ ] Run the deployment job in a larger runner to finish first
* [x] Choose one event to own deployment and document that choice
* [ ] Trigger deployments from every pull request event instead

> **Explanation:** Opening and merging a pull request are separate events, and a merge also creates a push. Decide which event owns each step so the same release is not deployed twice, and serialize conflicting deployments.

#### Q. During a rolling update, what must the team plan for?

* [x] Old and new versions serving traffic at the same time
* [ ] Running two full production environments in parallel
* [ ] Exposing the change only to staff before any customer
* [ ] Taking the service fully offline between the batches

> **Explanation:** A rolling update replaces instances in batches, so old and new versions coexist until it finishes. Both must handle the same data, messages and API contracts. A second full environment describes blue/green.

#### Q. A team wants to switch all traffic between two complete environments in one step and switch back quickly if needed. Which strategy fits, and what is its main cost?

* [ ] Canary, with the cost of a long and careful observation window
* [x] Blue/green, needing extra capacity and data compatibility
* [ ] Rolling update, with old and new instances coexisting
* [ ] Feature flags, needing a flag service for every user

> **Explanation:** Blue/green prepares a second environment and switches traffic to it. It needs extra capacity, and both environments usually share data, so the schema must suit both versions.

#### Q. What is the difference between a feature flag and a traffic-based canary?

* [ ] A flag routes requests between versions; a canary toggles code paths
* [x] A flag toggles behavior inside code; a canary picks a version per request
* [ ] A flag needs a second full environment; a canary needs no monitoring at all
* [ ] A flag is used only in staging; a canary is used only in production

> **Explanation:** A feature flag controls behavior inside already-deployed code, while a traffic-based canary controls which version handles requests. They can be combined, and both separate deploying code from exposing it.

#### Q. Version 2 ran a migration that dropped a column version 1 reads. Rolling back to version 1 makes every request fail. What was the underlying mistake?

* [ ] The old artifact had been deleted from the registry
* [ ] The rollback should have used a canary at 1% first
* [x] The migration was not backward compatible with version 1
* [ ] The team should have restored the database to last week

> **Explanation:** Application rollback works only if the older version can still read the current data and configuration. Backward-compatible (expand-and-contract) migrations keep the previous release usable; restoring the database would discard later writes.

#### Q. A CI job's dependency cache is evicted, and the next run is slower but produces the same test results. How should this be viewed?

* [x] Correct behavior: a cache should affect only speed, not results
* [ ] A release failure, because the cache is the deployable artifact
* [ ] A security incident, because caches hold production secrets
* [ ] A flaky test, which should be rerun until the cache is restored

> **Explanation:** Caches are speed optimizations; a miss should change timing, not correctness. The build artifact is what gets published and promoted, so keep caches and release artifacts distinct.

#### Q. A test fails about one run in ten, and developers rerun the pipeline until it passes. What is the better response?

* [ ] Mark the test as optional so merges are never blocked
* [ ] Add an automatic retry that reruns the job three times
* [x] Investigate it and give the flaky test a visible owner
* [ ] Increase the pipeline timeout so the test has more time

> **Explanation:** Rerunning until green hides the cause and erodes trust in CI. Investigate recurring failures, make the flaky test's owner and repair plan visible, and fix its dependence on timing, order or shared state.

#### Q. Which ordering of CI checks gives the fastest useful feedback?

* [ ] Full end-to-end suite first, then unit tests if time permits
* [x] Lint and unit tests first, then integration, then focused E2E
* [ ] Integration tests first, then formatting checks before merge
* [ ] Manual QA first, then unit tests on the release branch only

> **Explanation:** Start with fast checks such as formatting, linting, static analysis and unit tests, add integration tests for important boundaries, and keep slower end-to-end tests focused on essential user journeys.

#### Q. A project has 95% line coverage, yet a bug in an error-handling path reached production. What does this illustrate?

* [ ] Coverage should be raised to 100% to prevent such bugs
* [x] Coverage shows code ran, not that tests catch failures
* [ ] Error-handling paths cannot be tested by unit tests
* [ ] Coverage tools ignore code that throws exceptions

> **Explanation:** A coverage percentage reveals untested code but not whether tests assert meaningful behavior. Test important behavior and failure paths; review any threshold as the code changes.

#### Q. Two pull requests each pass CI on their own. After both merge, `main` fails its tests. What should the team do?

* [ ] Nothing, because each change was verified separately
* [ ] Disable the failing test until the next planned release cycle
* [x] Repair or revert the change quickly so main stays usable
* [ ] Move all future work onto long-lived feature branches

> **Explanation:** Individually passing changes can interact badly, so CI also verifies the integrated main branch. When main breaks, repair or revert promptly so other work can continue.

#### Q. A required check was skipped because of a path filter, and the pull request shows no test results. What does that mean for the change?

* [ ] The tests passed, because skipped checks count as success
* [x] There is no evidence the tests passed for this change
* [ ] The tests failed, so the pull request must be closed
* [ ] The check ran on the default branch instead of the PR

> **Explanation:** A check that did not run is not evidence that a test passed. Make sure required checks still report a result, for example when superseded runs are cancelled or paths are filtered.

#### Q. Integration tests pass locally but fail in CI when run in a different order, because they share rows in a database. What is the right fix?

* [ ] Run the tests in CI in the same order as on laptops
* [x] Make each test set up and clean up its own data
* [ ] Point the CI tests at the production database instead
* [ ] Retry the failing tests until the order works out

> **Explanation:** Tests should set up their own data and avoid relying on execution order, production services or another developer's machine. Independent tests can also be parallelized safely.

#### Q. In this workflow, the `test` job cannot find the `dist/` directory created by `build`. What fixes it?

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@<full-sha>
      - run: npm ci && npm run build
  test:
    runs-on: ubuntu-latest
    steps:
      - run: ls dist/
```

* [ ] Add `needs: build`, since jobs then share the same runner workspace
* [x] Upload `dist/` as an artifact, then add `needs: build` and download it
* [ ] Rename the jobs so `test` sorts after `build` and runs second in order
* [ ] Set `timeout-minutes` on `build` so it finishes before `test`

> **Explanation:** Jobs run independently on separate runners unless `needs` declares a dependency, and they do not share a filesystem. Pass files with artifacts or other explicit storage. Steps within one job share that job's runner.

#### Q. A workflow sets `permissions: contents: read` at the top level. What effect does this have?

* [ ] It blocks the workflow from checking out the repository
* [x] It limits the job token to reading repository contents
* [ ] It grants read access to every secret in the organization
* [ ] It makes the workflow run only on read-only branches

> **Explanation:** `permissions` sets what the automatically provided `GITHUB_TOKEN` may do. Granting only `contents: read` follows least privilege; jobs that need more should request it explicitly.

#### Q. Why is this step risky in a workflow triggered by pull requests?

```yaml
- run: echo "Testing ${{ github.event.pull_request.title }}"
```

* [ ] Echo commands are not allowed in GitHub-hosted runners
* [ ] Pull request titles are always empty in `pull_request` events
* [x] The untrusted title is inserted into the script before it runs
* [ ] Expressions inside `run` are evaluated only after the step ends

> **Explanation:** The expression is expanded into the shell script text, so a crafted title can inject commands. Pass external values through an `env:` variable and quote that variable in the script instead.

#### Q. A `pull_request_target` workflow checks out the pull request's head commit and runs `npm test`. Why is this dangerous?

* [ ] `pull_request_target` cannot run tests on hosted runners
* [x] Untrusted code runs with the base repository's privileges
* [ ] The workflow tests the base branch, so the PR is untested
* [ ] It runs tests twice, once for each branch in the pull request

> **Explanation:** `pull_request_target` runs in the context of the base repository and can access secrets and a write-capable token. Executing the contributor's code there, including install and test scripts, lets that code use those privileges.

#### Q. Why should third-party actions be referenced by a full commit SHA rather than a tag like `@v6`?

* [ ] SHAs make the action run faster on hosted runners
* [x] A tag can be moved to different code; a SHA cannot
* [ ] Tags are only supported for actions owned by GitHub
* [ ] SHAs automatically receive security updates from GitHub

> **Explanation:** Tags are mutable, so a compromised or changed tag can point to new code. Pin to a reviewed full commit SHA and update pins deliberately; the SHA does not update itself.

#### Q. A deployment job uses OIDC and requests `id-token: write`. What decides which cloud resources the job can access?

* [ ] The `id-token: write` permission alone grants admin access
* [ ] The repository's branch protection rules on `main`
* [x] The cloud role's trust policy and its attached permissions
* [ ] The runner's operating system and installed CLI version

> **Explanation:** `id-token: write` only allows the job to request an identity token. The cloud provider's trust policy decides which workflows may assume the role, and the role's permissions decide what it can do. Keep both narrow.

#### Q. A public repository uses a persistent self-hosted runner for pull request tests. What is the main risk?

* [ ] Self-hosted runners cannot run Node.js test suites
* [x] PR code can access the runner and anything it can reach
* [ ] Jobs on self-hosted runners ignore the `permissions` key
* [ ] Self-hosted runners always expose the repository publicly

> **Explanation:** Code run by a job can access the runner machine and its reachable resources, and a persistent runner can be tampered with for later jobs. Isolate runners used for untrusted work and replace them after use.

#### Q. A canary at 5% passed CI, but its HTTP 5xx rate is 3% against 0.2% for the stable baseline. CPU and memory look normal. What should happen?

* [ ] Continue to 25%, because resource usage is within limits
* [ ] Wait for 100% rollout to get a statistically larger sample
* [x] Stop expansion and return traffic to the stable version
* [ ] Restart the canary pods so the errors clear from the logs

> **Explanation:** The canary breaches an agreed error-rate stopping rule compared with the baseline, which matters more than healthy resource metrics. Stop expanding, shift traffic back to stable (with enough capacity ready) and investigate.

#### Q. A canary is shown only to internal staff for two hours and looks healthy. Why might that not justify a full rollout?

* [x] Staff traffic may not represent real customers' behavior
* [ ] Internal users can never trigger application errors
* [ ] Two hours is longer than any canary should normally run
* [ ] Canaries must always start at exactly 1% of all traffic

> **Explanation:** Cohort differences matter: staff or one region may use different features, devices or data than other users. Compare representative traffic, or add other evidence before expanding.

#### Q. A service receives only a few requests per hour. How should its canary be adapted?

* [ ] Skip the canary and deploy straight to 100% at night
* [ ] Use the same 10-minute window as high-traffic services
* [x] Use a longer observation window or add synthetic checks
* [ ] Judge it only by CPU usage, since errors are too rare

> **Explanation:** Low-volume services produce too few requests in a short window to reveal problems. Lengthen the observation window or add synthetic checks so the comparison has enough evidence.

#### Q. A release changes how a nightly batch job deletes expired records. Why does a 1% request-based canary give little protection here?

* [ ] Batch jobs cannot be deployed with the same artifact
* [x] Background jobs can bypass the traffic split entirely
* [ ] Canaries only work for read-only database queries
* [ ] Deletions are always reversible with a rollback

> **Explanation:** A traffic-based canary limits exposure for requests routed through the split. Background jobs and destructive data changes can affect all data regardless of the cohort, so they need separate safeguards.

#### Q. A team keeps its `kubectl apply` deploy script in Git and runs it from CI after each merge. Why is this not GitOps by itself?

* [ ] GitOps forbids storing deployment logic in version control
* [x] No agent continuously reconciles the cluster with Git
* [ ] GitOps requires every deployment to be approved manually
* [ ] The script must be written in YAML instead of shell

> **Explanation:** GitOps requires declarative desired state that agents pull and continuously reconcile. A pipeline that runs a versioned script once gives the script history but does not detect or correct later drift.

#### Q. During an incident, an engineer scales a Deployment by hand. Minutes later, Argo CD sets it back to the old replica count. What should the team do?

* [ ] Disable the controller permanently so manual fixes persist
* [ ] Delete the Deployment and recreate it with `kubectl create`
* [x] Record the emergency change in Git so the source matches it
* [ ] Restart the controller so it forgets the previous state

> **Explanation:** The controller reconciles drift according to its policy, so an undeclared manual change can be undone. Document how emergency changes are made and captured in the source of truth so reconciliation does not reverse them unexpectedly.

#### Q. A bad release deleted customer records. The team reverts the GitOps configuration commit, and the controller redeploys the previous version. What is still true?

* [ ] The deleted records are restored along with the old version
* [ ] The database schema is rolled back to match the old commit
* [x] The deleted data must be recovered through the backup plan
* [ ] The revert must be repeated until the records reappear

> **Explanation:** Reverting configuration can restore an earlier artifact or setting, but it does not undo database writes or restore deleted data. Verify health after reconciliation and use the recovery plan for data loss.

#### Q. A pipeline shows a green CI job for a commit. What does that tell you?

* [ ] The commit is deployed and every user journey works
* [x] The job's configured commands finished successfully
* [ ] The artifact was promoted to production automatically
* [ ] The cloud account has the permissions it needs to run

> **Explanation:** A green job means only that its configured commands succeeded. Read the pipeline definition to learn what it actually checked; it does not imply deployment or full functional coverage.

#### Q. A Python service using an SDK gets `AccessDenied` when reading an object storage bucket, even though its credentials are valid. What is the likely issue?

* [ ] The service failed authentication and has no identity
* [x] The identity is authenticated but lacks permission
* [ ] The SDK cannot read buckets without the web console
* [ ] The bucket must be in the same region as the developer

> **Explanation:** Authentication establishes who the caller is; authorization decides what it may do. A valid identity can still lack access due to its policies, the bucket's policy or other restrictions.

#### Q. Before running a deployment command from your laptop, which AWS CLI command confirms which account and role your configured profile is using?

* [ ] `aws configure list-profiles`
* [ ] `aws s3 ls --profile learning`
* [x] `aws sts get-caller-identity`
* [ ] `aws iam list-users`

> **Explanation:** `aws sts get-caller-identity` returns the account, ARN and user or role ID for the current credentials. Check account, region and identity before making changes, and avoid sharing the output from private environments.

#### Q. A front-end team wants browser code to upload files straight to cloud storage. What is the appropriate design?

* [ ] Embed a long-lived cloud access key in the JavaScript bundle
* [x] Have the server issue a signed URL with limited scope and expiry
* [ ] Create one IAM user per website customer for direct uploads
* [ ] Make the bucket publicly writable so uploads need no identity at all

> **Explanation:** Browser code must not contain a server's cloud credentials, and website customers normally have application identities, not IAM users. Signed URLs allow direct access with explicit authorization and expiry.

#### Q. A CloudFormation update changes a property on a database resource. Why review the change set before executing it?

* [ ] Change sets are only required when resources move to a new region
* [ ] Executing a change set without review deletes the stack's tags
* [x] Some property changes replace the resource instead of updating it
* [ ] CloudFormation never updates resources in place after creation

> **Explanation:** Depending on the property, an update can modify a resource in place or replace it, and removed resources can be deleted unless retention policies apply. Review the change set and protect persistent data before executing.
