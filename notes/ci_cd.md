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



## Probelms

I need scripts to run on github webhooks just as bad as you do. But this one-size-fits-all "lets make scripts but in yaml" shit has got to go.

Every CI/CD engine has a million different 'input' layers - environment variables, repo variables, workflows from various branches, maybe the git commit object. Oftentimes your scripts will have the ability to jam more variables into the 'input' layer for later scripts - such as in the case of the github environment variables. UNFORTUNATELY, it's never clear WHICH input layers are available to WHICH parts of the script. "Oh, no, you can't use outputs from this script to as arguments for something in our yaml, because the yaml is calculated first." Well thanks, Mr Nadella, I'll just torch my entire pipeline and start over.

Every CI/CD engine is trying to have some sort of rudimentary 'secrets management', but that's not its core competency. There are always rules - "only 100 secrets", or "Secrets can't be passed from job to job," or "We allow secrets but you can only put them in via our GUI" or "We use hashicorp vault as a secrets backend but we didn't study the docs so we're just using their 'approle' backend as a username/password." Looking at you, Mr Tabib.

Every CI/CD has obscure, insane 'defaults' left and right. "Oh, you ran a job that was called by another job called by another job, and everything succeeded, but one of the if statements didn't run? Our 100% proprietary fancy-pants no-source observer calls that a failure!"

FOR GOD'S SAKE, YOU ARE A GLORIFIED SCRIPT RUNNER.

I'm dying over here, you guys. What happened to the unix principle? What happened to each thing doing one thing really, really well and stringing it all together? Why does each CI/CD runner have a GUI and a CLI and two APIs and secrets management and slack integration and built in graphs and dashboards and runs shell scripts against my cappucino maker?!

Like, SO MUCH of our CI/CD in every place I've ever been could be done with docker containers and python. Github pull request? Send a webhook to the container, run the scripts, fuck off. Am I missing a GUI I admit it might be a little irritating to build my own GUI, but everything else? Emailing people from a script? Slacking people from a script? Correctly gathering secrets from my vault instance from a script? CORRECTLY PASSING RETURN VALUES BETWEEN SCRIPTS?!

But instead, I spend my days becoming a goddamn little cackling wizard on someone's particular dumbass piece of software with features we'll never use, hidden 'sane defaults' that get in the way, security that protects someone else, translating yaml to basic-bitch bash.

We have saved so much headache by doing one simple thing with our CI pipelines: no scripting goes in the script block. Just call external scripts. Use whatever lang you want, however you want.\

ep, this is it. This is all you need to keep in mind. This will cumulatively save 100s and 100s of hours. It really is that simple. It's worth being redundant about here, even though I'm not adding anything, because people rarely remember tips based on how much of a boost it is, but based on how much time they've spend thinking about it. Unfortunately, the time it takes to explain the concept of not putting scripting logic into ci/cd config, but instead, a script of its own, is not proportional with how awesome a tip it is, so for the benefit of everyone else:

Do not put scripting logic in hard to test YAML.
Do not put scripting logic in hard to test YAML.
Do not put scripting logic in hard to test YAML.

Put scripting logic in an easy-to-test script.

Put scripting logic in an easy-to-test script.

Put scripting logic in an easy-to-test script.

Source: Learning this the hard way. I am in charge of tooling for a dev process, and have written 100s of scripts. In the beginning, I realized this, but I didn't realize how universal this rule is, and I let it get the better of me. Now I do my rosemary 20-chantings to drill it into my brain.

My org still uses Jenkins, and it's because we take this approach. All our ci is defined in Makefiles, so all we use Jenkins for is basically just a webhook listener and GUI for parameters for manual executions.

This also has the benefit that all of your pipeline code can be developed, tested, and controlled by proper GitOps processes. No more blocks of code inside yaml that can only be executed from the CI/CD engine.

Also, goodbye costly vendor lock. My pipeline can run anywhere that can run containers.
