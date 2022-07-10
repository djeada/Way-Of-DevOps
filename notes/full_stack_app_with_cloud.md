For instance, when we write code in our IDEs we are connecting *somehow *to the AWS console (not sure how) 
and here we have access to AWS services and we sort of pick and choose which ones fulfill the job requirements. 
Don’t really get how we make the connection through our IDE to our companies personal AWS account and how we are 
able to access things like S3 or Aurora.

Another aspect outside of how we are connecting to the AWS console/companies personal AWS account is how github 
and Jenkins fits into all this. Like when I make a commit and push my code to the companies github repo how is 
it getting sent to Jenkins and what exactly is Jenkins doing here? When I go to our Jenkins page I see a bunch 
of either passes/fails — what is even happening here? How does Jenkins fit into this whole equation, 
why do we need it? Github more or less makes sense to me as it is a way for the team to make additions onto 
the current code and keep everyone on the same page as far as accomplishing the tasks.

A third part, which might be the most confusing part of all is how the company uses the code the developers make and 
how the end customer interacts with our code. So say we have accomplished the task of making a rest api for our company. 
This whole time we are developing on the companies AWS account but we are developing it for a contract — so how does it
get from our AWS account to the contracts AWS account? Also I assume all this ultimately gets packaged up somehow and 
deployed as actual software/api (need clarity on how that process works).

And how is the customer accessing/using the rest api? Like if they sign up and login to the website and make some 
purchases are they treated like an IAM user? And when they click things is it like they have a personal IAM AWS 
user account that uses S3 and aurora but on our behalf? Can someone please clear up how is this whole process works?

TLDR; Don’t understand the whole connection between developing on my own machine, sending that code to github, 
then having that go to Jenkins for a pass/fail and then ultimately the whole process of the end customers being able 
to interact with and use the REST api?

So the thing you need to understand is that AWS is a collection of services, these services can all be accessed either 
through the web UI console, or through the SDK's or CLI. Everything you can do in the console can be done using an API 
call using the SDKs or CLI.

Both the SDKs and CLI have a concept of a credential provider, when you make e.g a call to S3 for example using the CLI

aws s3 ls
The SDK/CLI will have a list of places ( https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/credentials.html) 
to check and see if you have credentials for a specific AWS account, if you don't have any credentials then both the CLI
and SDK will throw an error about an invalid token or something along those lines.

If you do have credentials set in your environment (usually these are temporary credentials issued by IAM and expire every 
few hours or so to prevent unauthorized access if the credentials get leaked to GitHub or whatever), then as far as the SDKs 
are concerned, any call you make will be "inside" this account. So if you export different credentials for different accounts 
then you'll be able to directly query resources in those accounts. (I would hazard a guess that your IDE has some extension 
enabled which automates this credential retrieval)

Now, you might notice how tedius it is to create resources like s3 buckets, ec2 instances etc manually in the console, it also 
means if you want to "transfer" these to a different account you'd basically need to remember all the steps you did. Luckily
AWS has already figured this problem out in the form of Cloudformation (CFN). Cloudformation is an AWS service whereby you can 
specify the resources you need and their relationships in either JSON or YAML, Then all you need to do is hit upload on the template 
and based on what you wrote, all the resources will be provisioned exactly as described. In this way you would be able to have 
multiple cloudformation templates for multiple components, and able to replicate them across accounts with ease.

Another issue might arise from the above now as you still need to manually deploy these templates across numerous accounts (think
replicating between a development environment and a production environment. Also you might need to replicate all the resources again
if your service is to be available in multiple AWS regions)

Now, if the DevOps team have set up their CI/CD correctly, then basically what happens is when you push to say GitHub, Jenkins gets 
notified that there has been a merge. Jenkins will then get these cloudformation templates and basically call the SDKs to upload 
them to the different accounts and regions as needed, if you have a codebase then perhaps it might build docker images for the current 
codebase and upload them to AWS ECR, updating the cloudformation template with these new docker images tags so that on the next deployment 
your ec2 instances will use this new docker image. Adding a new account or region would be as simple as duplicating a stage in the pipeline 
and passing different parameters like e.g the account and the region to deploy to.

In this way, you can define resources/code, push them to github, and Jenkins can deploy your changes automatically. Now of course it's bad 
practice to just automatically deploy to production, so before it gets to this stage there would probably be different validations that need 
to be done. For example, running unit tests, integration tests etc. Once these pass then perhaps Jenkins will then deploy to production.

When we use the AWS CLI I recall I’d connect to our personal unique AWS account using credentials is that in effect the same as using the 
AWS SDK? It being the connector between our local machine and our personal unique AWS account?

I don’t think my company has automatic credential retrieval bc each time I’ve made executions linking my IDE code to AWS I use the AWS CLI 
and then log in the credentials using a copy-and-paste method each time to launch my code locally to AWS console.

I think I do understand what cloudformation template is doing, effectively it allows us to provision all the resources and relationships 
between those resources and launch that same unique thing as many times as we’d like. So that could be an api gateway, lambada, aurora 
doesn’t matter, can make that template once on our machine and then launch it multiple times. I don’t fully understand the region part, 
I know that not all services are available everywhere but what does replicating them again do? for example say in south-Africa-2a there 
isn’t the availability for ec2 how do we handle that? Does that mean our rest api won’t work there?

In terms of making a rest api why would we want to replicate the same cloudformation over and over again? I don’t understand how the 
cloudformation concept relates rest api.

What is the main difference between a develop environment and production environment?

Also, if by codebase you mean a large amount of code with hundreds of files then yes. I think that is a docker component in the process 
but I don’t quite understand what it is doing. Docker per this definition I found is:

“Docker is a container management service that enables developers to package applications into containers—standardized executable components 
combining application source code with the operating system (OS) libraries and dependencies required to run that code in any environment.”

So basically we can contain the entire essence of the environment of our local computer into a box and then experiment inside that isolated box?

I don’t understand the difference between a Cloudformation template and simply building something through boto3 like an ec2 instance. If I create 
a python file and then inside that create an ec2 using boto3 then launch it to AWS isn’t this in effect the same as if I created a cloudformation 
template and provisioned room for that ec2 instance? Or is idea here that the cloudformation file exists to provision those resources and then we 
use separate py files to run some commands/execution upon those newly provisioned resources?

There also appears to be many different ways of testing our code to ensure it is working the way we expect, correct me if any of this is wrong. 
The first is send the code off via the AWS CLI to the AWS console and check the logs and see how it is doing there. Second is to launch the code 
locally and see if our unit tests are passing or failing. Third Is to launch the code to our github repo which in effect sends it off to Jenkins 
and we can see how it works there.

From your experience how does one send code from our local machine to the AWS console? I recall using AWS CLI but unsure how it is done. Could you 
explain your knowledge about CodeCommit, CodePipeline, CodeBuild, and CodeDeploy and how they fit in here?

Finally there is AWS SAM and understanding how that fits into all this. SAM has its own CLI but unsure how that fits into our system.

The definition I found for AWS SAM was this:

“The AWS SAM CLI is a command line tool that operates on an AWS SAM template and application code. With the AWS SAM CLI, you can invoke Lambda 
functions locally, create a deployment package for your serverless application, deploy your serverless application to the AWS Cloud. AWS SAM is 
an extension of AWS CloudFormation, so you get the reliable deployment capabilities of CloudFormation. You can also define resources using 
CloudFormation in your SAM template and use the full suite of resources.”

That definition doesn’t help too much it seems a bit too abstract.

Regarding SDKs, they're just a library that allows you to call the AWS APIs basically. They are distributed in a few languages like Java, Python, 
JavaScript etc. The basic idea is that you create e.g an S3 object which is in itself an S3 client, then this client let's you send commands like 
create bucket, upload file to bucket etc etc.

Fun fact, the CLI is actually written in Python. For every call through the CLI it actually does some magic in the background and invokes the 
corresponding function in the Python SDK

On Cloudformation vs SDK calls. The neat thing about cloudformation is that it holds a reference to the existing resource, so let's say you call 
the SDK to create an ec2 instance. If you run that script again it will just provision a new instance as many times as you run the script. With 
cloudformation any change you make will update the EXISTING instance, also removing the resource from the template actually triggers a deletion.
Otherwise you would need to remember to e.g create the ec2 instance, then make calls to update it which isn't great if you think about it (what if
you accidently create a new one? What if you come back months later and want to change something about the instance, how will you remember what
commands you invoked?) Think of Cloudformation as a declarative way of defining the resources in your account. (Btw in a real production environment 
everything should be either a CDK stack (more on that later) or a cloudformation template. You should never run a script which manually updates the
instance provisioned in cloudformation, if you do then the next time you upload your cloudformation template, all of your manual changes will be
reset to how the resource is defined in the cloudformation template

Regarding "sending code to the AWS console". Again, you need to think about AWS as a collection of services, these services can interact with each 
other and provide functionalities for you. No code is sent to the AWS console. In AWS terms you would build your code using e.g docker. You would 
 then store this docker image in ECR (AWS docker repository basically) then you would pull that docker image from ECR when your ec2 instance starts 
 and run that container. If you want it reachable from the internet then you would use e.g route 53 to point to an AWS resource like an AWS EC2
 instance. I'm leaving out some architecture as to not overwhelm you but this is the basic premise. Things aren't magically done for you, you don't
 really send code anywhere, you utilise different services together to create your application

Now, what I said about building the docker image and uploading then getting the ec2 to point to the new image is quite tedius if you think about 
how many different images and instances you could have. (At my job we have over 1500 ec2 instances which deploy new docker images every single week
so you can imagine how tedius it could be if it was manual) this is where codecommit, codebuild etc come in

Codecommit -> Amazon's git repository service (store your code here, it might be synched automatically from GitHub if your team has it set up)
Codebuild -> Amazon's service for building your code from code commit (you basically supply a list of commands i.e compiling code and building 
docker images) CodeDeploy -> Amazon's service for deploying your infrastructure (again, another list of commands for uploading docker images
and e.g uploading cloudformation templates)

Codepipeline -> brings all the above services together. Here's an example pipeline

Let's say you have repository A and repository B which is java code. You would add an action which listens on codecommit for a commit, when
there's a new commit the pipeline is triggered. After the code is retrieved, it's sent to codebuild, codebuild will take your code, and then
based on the commands you wrote it will execute them on the pulled repository (i.e javac xxxx, docker build xxx). You then configure codebuild 
to output the built code/docker images to code deploy. Again another set of commands are executed which will i.e (AWS ECR put-image Xxxx, or
cloudformation update-stack yyyy)

You repeat this deploy stage for all your different accounts/regions and voila, you have created a CI/CD pipeline. (Again it's a small bit more 
complicated than this but I could write paragraphs upon paragraphs on the intricacies of all these parts)

So the drawback about Cloudformation is that you could call it very verbose, you need to define everything and know how all different components 
work then look up their definitions etc etc in order to build a proper cloudformation template. The cool thing about it though is that you can
write your own resources if you wanted to (called custom resources) which could do a range of functions. SAM is basically this, what it will do 
is define a custom resource (I think AWS::serverless but I'm forgetting) but basically it provides an abstraction on Lambda so it's easier to
]work with. I believe what you can do is specify your code locally, and SAM will automatically get your code, upload it to an S3 bucket, and
then reference that code in the handler of the lambda function (otherwise if you use the standard lambda you would need to upload this code 
yourself manually, and then link it to the cloudformation resource which can be tedius), it also does what you said there like allowing you to 
run lambdas locally and all that. To be honest me and my team don't use SAM at all and we are actually moving away from Cloudformation templates 
as a whole.

This is where CDK comes in, basically it's an SDK for cloudformation! So you can actually write your template as code in your favourite programming
language, and it will automatically generate the cloudformation template and upload things too. E.g if you wanted an S3 bucket you would just do

Const bucket = new S3.Bucket({BucketName: "test-aws-bucket});
Then you can deploy that using the CDK CLI and it will automatically generate a cloudformation template and provision the resources, it's basically 
what you were talking about awhile ago, but the key thing is that it keeps a reference to the resource. If I commented out the above code and then
redeployed, it would effectively delete the bucket. If I wanted to come back and add e.g SSL on the bucket I could so easily by modifying the above 
code to

Const bucket = new S3.Bucket({BucketName: "test-aws-bucket", sslEnabled: true})
That's the basic idea anyway, as you get more familiar with the resources you'll find that you can link them together (i.e linking an SQS queue to
a lambda function to process messages, or an S3 bucket to CloudFront to cache files at the edge or something)
