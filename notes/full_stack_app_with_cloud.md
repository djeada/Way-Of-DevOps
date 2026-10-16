# How a full-stack application reaches the cloud

There are two related paths to understand: how a change becomes running software, and how a customer's request reaches that software. GitHub, a CI runner, and cloud services have different jobs in those paths.

## From source code to a deployment

1. A developer edits code locally, runs tests, and pushes a revision to GitHub.
2. A repository event notifies a CI system such as Jenkins or GitHub Actions. The runner checks out the code and executes the configured commands.
3. Passing checks produce an artifact: a package, a container image, a static site bundle, or a function deployment package.
4. The artifact is published to a registry or object store. Infrastructure code describes the resources needed to run it.
5. A deployment process updates the target environment to use that artifact, then checks health and behavior.

A green CI job means its configured commands succeeded. It does not automatically mean the application was deployed or that every user journey works. Read the pipeline definition to learn what the job actually checked.

Code runs on compute services, such as a VM, container service, or function runtime. The cloud console is a management interface where people inspect and configure resources; application code is not executed inside the console.

## How a machine authenticates to AWS

The console, CLI, and SDKs are different ways to call service APIs. An SDK is a language library; for example, Boto3 lets Python code make AWS API requests. An IDE may invoke these tools or use an extension, but it still needs an identity and permissions.

Developers commonly use a federated sign-in flow that provides temporary credentials. Applications use workload roles, and CI can use an identity federation flow such as OIDC. SDK credential providers obtain credentials from supported sources; the exact lookup order depends on the SDK.

For an already configured AWS CLI profile, `aws sts get-caller-identity --profile learning` shows the caller identity. Use the account and role information to check the target; do not publish identity output from a private environment unnecessarily.

Permission is separate from authentication. A valid identity may still lack access to a bucket or database. Network connectivity, service policies, and database authentication can impose additional restrictions.

## How a customer uses the application

For a typical web application, DNS resolves the public name to an entry point such as a CDN, load balancer, or API gateway. The customer connects over HTTPS. The entry point routes the request to the application, which validates the customer's session or token and performs authorized work.

The application can then use its workload identity to access services such as S3. A database connection also needs the database's supported authentication and authorization. The response returns through the entry point to the customer.

A website customer normally has an application identity, not an IAM user. Browser code must not contain a server's cloud credentials. Direct client access to cloud storage can be designed with limited mechanisms such as signed URLs, but it requires explicit authorization and expiry.

## Infrastructure code and application code

A CloudFormation template declares AWS resources and their relationships. CloudFormation manages them as a stack. An update can change a resource in place or replace it, depending on the property; removing resources can delete them unless retention policies apply. Review the proposed change set and protect persistent data.

A Python script calling `create` APIs performs imperative operations. Making it safe to rerun requires explicit handling of existing resources and failures. IaC tools supply a resource lifecycle model, but also require correct configuration and review.

AWS CDK defines infrastructure in programming languages and synthesizes CloudFormation templates. AWS SAM provides serverless-oriented template constructs and a CLI for building, testing, packaging, and deploying applications. Choose the authoring approach the team can maintain; these are not all mandatory layers.

Manual changes can cause drift. Do not assume every later stack update will automatically repair every manual change. Detect differences, inspect the impact, and reconcile them deliberately.

## Accounts, regions, and delivery services

Development, test, and production environments separate data, access, and change risk. They may use separate accounts and different capacity while sharing the same infrastructure modules and application artifacts.

Deploying to a customer's account requires an agreed access model, often a narrowly scoped deployment role in that account. Deploy the artifact and target-specific infrastructure there. Data migration, credentials, DNS, and permissions remain separate work; resources do not simply move with a Git push.

A deployment region controls where regional services run. Customers elsewhere can often call the public application without a deployment in their own region. Extra regions can improve latency or recovery, but need a plan for data, routing, and consistency. A region and an availability zone are different concepts.

AWS delivery services can implement parts of this flow: CodeBuild runs build commands, CodeDeploy manages supported application deployments, and CodePipeline coordinates stages. Source control may remain in GitHub. These are alternatives or integrations with other CI tools, rather than required steps for every AWS application.

References: [temporary credentials](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp.html), [CloudFormation update behavior](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-updating-stacks-update-behaviors.html), and [CloudFormation drift detection](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-stack-drift.html). Continue with [CI/CD](ci_cd.md) and the [Floci labs](../labs/floci/README.md).
