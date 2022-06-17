It's essential to know about:

Terraform is not a silver bullet and cannot replace absolutely all tools. To configure virtual machines, it is better to use the following tools:a) Packer;b) Ansible/Chef/Puppet/Salt;c) Whatever you want (bash?).

Terraform is not a multi-cloud management tool. It can be called so with a huge stretch. By managing only AWS, you cannot deploy the infrastructure in the GCP using the same code. Each provider has its own set of resources, and these resources are called differently. However, the use of Terraform allows us not to learn the new syntax of various tools and new approaches to organizing code for working with different clouds/providers. Which at times speeds up the process of writing, maintaining, and transferring code between engineers.

Knowledge requirements:

Ability to read someone else's terraform code. It means that you can read and understand the code used in the public modules (input/output parameters, logic, resources used); 

Fluent usage of public modules;

Ability to describe the infrastructure of the project in the form of readable, maintainable and reusable code;

Writing your own modules and understanding how to use them;

Understanding how to organize the structure of the project;

Manually work with a state file (importing existing resources into code, deleting objects, moving objects between resources (for example - from a resource to a module));
