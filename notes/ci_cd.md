CI/CD

It is now impossible to imagine any project that wants to reduce Time-To-Market without losing quality and doesn't use CI / CD (Continuous Integration / Continuous Delivery / Continuous Deployment) processes. Therefore, it is vital to understand the concepts and apply them correctly. Our task is often to write a pipeline regarding the development and source code flow. Let's consolidate the idea that we don't pull the flow on the pipeline but adjust the pipeline to the flow. Now it is practically not important which CI / CD system will be used, because they all have pretty much the same functionality. BUT it is important to remember that EDGE cases exist, and knowing the strengths/weaknesses of a particular system will allow you to make the right choice at the right time.

Necessary knowledge in this field:

Understanding of the CI, CD, and CD concepts. Know what it is, and what the differences are.

Writing simple and readable pipelines;

Ability to transfer the development flow to the CI / CD pipeline, which may include complex logic:- rollbacks,- manual steps,- trigger other jobs, services,- notifications.;

Pipeline optimization. Ability to find bottlenecks, speed up, and optimize in terms of cost;

Knowledge of various strategies for rolling out a new release and the ability to implement them:- Rolling update,- Blue/Green;- Canary;

GitOps - what is it, when is it better to apply, and what tools are better to use;

Knowledge of tooling. Integrate infrastructure and application code analysis, images and systems for vulnerabilities, and security checks of public endpoints into pipeline steps.

## Building the project

- compiles the project

- runs plugins that generate docs

- runs all unit tests

- checks all the dependencies to look for security vulnerabilities

## General and Branching

* Team size ?
* What branching model are using (Trunk-based, GitFlow ...)
* Do you use Release branches and/or tags? what for? how ?
* Do you create Releases (GitHub/GitLab release)? and how (manually/automated...)?
* How do you manage bug fixes in releases (do you fix in main and cherry-pick, hotfix branches or other) ?

## Build and Deployment

* How many environment are you deploying to? how often ?
* What triggers a build?
* What triggers a deployment?
* Do you have environments that match your branches?
* Do you have any manual approval steps in your pipelines?
* How do you do rollbacks?
* Are you using any deployment strategies (blue/green, canary ...)?

## Answer
We have multiple teams of about 10 Devs each.

Each team has an entire environment that mimics live (an openshift cluster and a bunch of old server based stuff)

They can choose to subscribe that environment to different branches for each component (or just make them all follow develop)

Any commit to a branch for any component and CI will deploy that component to that team's environment.

Teams create feature branches for what they are working on from develop.

feature/team/branch-name

They might have sub feature branches depending on what's going on, as long as they keep it in their teams path no one else cares.

Eventually through code reviews and internal team QA (each team has a dedicated QA person) etc they will merge down to develop. They immediately take a release branch from develop.

release/yyyy-mm-dd-x

The feature branch should then be deleted.

CI then deploys that to integration and an internal only beta site (which operates on a copy of live data)

The QA team then does a massive load of both manual and automated integration tests. VRT tests and the like, with extra test suites depending on the components to be released. This takes about 5 hours.

Once they approve the merge request it's merged to a branch called production and the release branch is deleted.

This deploys it to live, typically for most stuff that's building a docker image, pushing it out to the docker registries for each data centre then using tanka to push deployment and config information to each openshift cluster in each DC.

The release manager is then supposed to tag production with the date and an incrementing number at the commit it was released at, but as it's a manual process sometimes they forget. I would like to automate this at some point.

Tag is just yyyy.mm.dd.x

At each merge / commit a suite of automated tests also run enforcing things like linting, code standards, passing unit tests, and static analysis, a failing pipeline won't be allowed to merge with develop, we have alerting for failing pipelines on release and production branches.

## Other Answer

Max 7 teammates

Close to trunk based

No release branches or tags. Version tags only but not always linked 1-1 to a release (most of the time it is though).

Yes, homemade tool. Manually when a developer wants to deploy. It automatically aggregates description and configuration changes for each branch merged up to the release.

It's very rare that we have hotfix to do. Most of the time it's fixed in a feature branch then merged in main branch as a new development because it's detected few minutes after deployment so nothing has changed in the meantime in the main branch.

Between 3 to 5 environments depending on the project. As often as possible: for each feature most of the time. Let's say once per day for a given project (or less often if the project has no change).

Build are triggered automatically by MR.

Manual demand to deploy.

Environments and code branches are not correlated. Excepted for dev environnement, all environment match the main branch.

Manual approbation of MR. Manual asking for deployment. But everything else automated (build and release, deployment itself).

Each rollback is different and handled manually because consequences of rollback have to be thought of.

Only for critical components we do canary mostly.

## Wisdom

- Nothing called RFC or Change , but it’s named Pull Request ( Code Merge Request)
- opening pull request is an EVENT , merging pull request is another EVENT
- opening pull request EVENT triggers CI
- merging pull request EVENT triggers CD
———
- there is nothing called dev/qa environments, but it’s PREVIEW environment ( per pull request) . The environment dies when the Pull request is approved ( even before merged ) which a 3rd EVENT.
- Prod of v1 becomes staging of v2 called also blue .. prod of v2 is green ..it’s promotion
———
- Do not allow manual versioning , but auto-calculate it from semantic git commits
- Use the auto-calculated version everywhere to Tag everything
———
- Do not rollback DB by SQL scripts but by Point-in-time recovery ( DB snapshot)

