# GitHub Actions

GitHub Actions runs workflows in response to repository events or an explicit request. Workflow files live in `.github/workflows/` and describe jobs, their runners, and their steps.

A workflow contains one or more jobs. Jobs run independently unless `needs` declares a dependency. Steps within a job run in order and share that job's runner. Separate jobs transfer files through artifacts or another explicit storage mechanism.

## Example: check the network lab programs

Save the following as `.github/workflows/network-labs.yml` in this repository to run the existing Node.js smoke tests. This is an example configuration; the note itself does not enable a workflow. The smoke tests need Node.js and OpenSSL, but do not verify Docker packet capture or Floci behavior.

```yaml
name: Network lab checks

on:
  pull_request:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read

jobs:
  smoke-tests:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - name: Check out source
        uses: actions/checkout@d23441a48e516b6c34aea4fa41551a30e30af803 # v6
        with:
          persist-credentials: false
      - name: Set up Node.js
        uses: actions/setup-node@949feb2413d6458794dcd2491c4babbbce0c15c1 # v7
        with:
          node-version: '24'
      - name: Run lab smoke tests
        working-directory: labs/wireshark-nodejs
        run: npm test
```

The labs have no npm package dependencies, so this example needs no `npm install`. For a project with a committed npm lockfile, install dependencies with `npm ci` before running tests. Keep project-specific commands in package scripts or separate files.

## Permissions and trust

Give each job only the permissions it needs. Pull request tests should run without production secrets. Treat pull request titles, branch names, and other external inputs as untrusted; pass needed values through environment variables and quote them in scripts.

Do not execute untrusted pull request code in a privileged `pull_request_target` workflow. Be especially careful with self-hosted runners: code run by a job can access the runner and its reachable resources. Isolate and replace runners used for untrusted work.

Pin third-party actions to reviewed full commit SHAs and update those pins deliberately. The example pins identify the referenced releases at the time of writing. For cloud deployments, prefer OIDC federation with narrowly scoped trust over a long-lived access key. An `id-token: write` permission permits requesting a token; the cloud trust policy still decides what it can access.

## Delivery and debugging

Use separate deployment jobs with environment protection rules where available, scoped credentials, and concurrency controls. A build artifact is the output to promote; a dependency cache is only a speed optimization.

When a workflow fails, inspect the event, checked-out revision, job permissions, working directory, and the first failing command. Verify that dependencies between jobs are explicit. Step outputs and environment variables have different scopes and should not be assumed to appear in every job.

References: [workflow syntax](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax), [secure use](https://docs.github.com/en/actions/reference/security/secure-use), and [pull_request_target](https://docs.github.com/en/actions/reference/security/securely-using-pull_request_target).
