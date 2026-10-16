# CI/CD

CI/CD automates the path from a source change to running software. A pipeline should make the team's delivery process repeatable and visible, with clear evidence for deciding whether a change is ready.

## Three related concepts

- Continuous integration (CI): developers integrate small changes frequently, and automated checks verify that the combined code still works.
- Continuous delivery: a passing change produces a deployable artifact. Production deployment can require an explicit decision or approval.
- Continuous deployment: every change that passes the required checks is deployed to production automatically.

CI does not require production access. Continuous deployment needs strong verification, monitoring, and a recovery path. Choose the release decision that fits the service and the team's responsibilities.

## A typical pipeline

1. Check out an exact source revision and install dependencies from lockfiles.
2. Run formatting checks, static analysis, unit tests, and relevant security checks.
3. Build a versioned artifact, such as a package or container image, and publish it to an artifact registry.
4. Deploy that artifact to a test environment and run integration or smoke tests.
5. Promote the same artifact to production after any required gates.
6. Check health and user-facing signals, then complete the rollout or stop it.

Build once and promote the same artifact between environments. Store environment configuration separately, and identify the deployed source revision and artifact digest. A mutable tag such as `latest` alone is insufficient for reproducing a release.

Pull request events commonly trigger CI; merges, tags, or explicit requests can trigger deployments. Opening and merging a pull request are separate events. Document which event owns each step so the same release is not deployed twice accidentally.

## Branches and environments

Short-lived branches and frequent integration reduce the amount of work that can diverge. Release branches can support maintained versions, but need a policy for fixes and merging changes back. GitFlow is one possible workflow, not a requirement for CI/CD.

An environment is a running configuration of the application. It does not have to correspond to a branch. A preview environment may belong to a pull request; staging and production may run different artifacts built from the same main branch. Remove previews when their work is finished, and use synthetic or appropriately sanitized test data.

## Releases and recovery

| Strategy | How it works | Main consideration |
| --- | --- | --- |
| Rolling update | Replace instances in batches | Old and new versions coexist during the rollout |
| Blue/green | Prepare a second environment and switch traffic | Extra capacity and shared data compatibility |
| Canary | Expose a small cohort before expanding | Representative traffic and reliable stopping signals |

Separate deploying code from enabling a feature when a feature flag helps control exposure. Remove flags once they have served their purpose.

Keep the previous artifact available and define who can stop a rollout. Application rollback works only if the older application can still read the current data and configuration. Use backward-compatible database migrations and test the recovery procedure. Restoring a database to a previous time is a disaster-recovery operation that can discard later writes; it is not a routine substitute for migration planning.

## Keep pipelines maintainable

Keep substantial build and test logic in versioned scripts or project commands that also run locally. Use the pipeline file to coordinate jobs, inputs, dependencies, and permissions. Avoid duplicating the same scripts in several CI products.

Set timeouts, serialize conflicting deployments, and distinguish caches from release artifacts. Cache misses should affect speed, not correctness. Give untrusted pull request jobs minimal permissions and no deployment credentials. Use short-lived credentials for trusted deployment jobs.

Measure feedback time, failed deployments, and recovery time. Investigate recurring failures rather than repeatedly rerunning jobs until they pass.

Related: [continuous integration](continuous_integration.md), [GitHub Actions](github_actions.md), [canary releases](canary_release.md), and [database operations](best_practices.md).
