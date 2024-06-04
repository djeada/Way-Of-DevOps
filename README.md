# DevOps

A comprehensive roadmap for aspiring and experienced DevOps engineers, designed to guide you through the essential skills, tools, and practices needed to excel in the field of DevOps. This repository offers a structured path, covering a wide range of topics from foundational concepts to advanced techniques, providing valuable insights and resources for continuous learning and professional development.

TODO:
* https://github.com/MichaelCade/90DaysOfDevOps
* https://forrestbrazeal.com/2020/04/23/the-cloud-resume-challenge/

PROJECTS:

* SETUP APACHE
* SETUP KERBEROS


Fundamentals:
* git 
* linux
* networking
* HTTP APIs standards
* serverless
* caching
* monitoring

Scripting:
* bash
* powershell
* python
* go

CI/CD:
It is a concept of automatizing the process of building a project, running tests automatically, running different checks on the software, deploying the software to different environments and also releasing it to production. Tools you can look into are: Github Actions / Jenkins / Teamcity. And from the checks side you can implement Sonar check, OWASP check and also integration with Upsource.
* Jenkins
* Travis Ci
* GitHub Actions
* Gitlab
* TeamCity
* AWS (Amazon Web Service) CloudFormation + AWS Code Pipeline
* Azure DevOps

Containerization:
* Docker
* Podman

Orchestration:
some companies are just dropping the application to client server and running it there. Others are using virtual machines. Third ones are using Docker. So you can look into how the web application be deployed and run in the client side. Also different methods require different means for maintenance. Don't know from the virtual machine side but from Docker side you can look into: Docker itself, Kubernetes, Docker Swarm.
* Kubernetes
* ECS

Infrastructure as Code:
* Ansible
* Cross Plane
* Terraform 
* CloudFormation
* Azure Resource Template

Databases:
Learn what happens behind your SQL queries. There is a difference between an SQL query and an SQL query. Or a difference between a database table and a database table. One query is executed instantly. Another query can kill the application. One table is optimized for SQL queries. Another table is not. Then you can look into different database systems and which one to use and when. For example PostgreSQL, Redis, DynamoDB... Each of them has their own pros and cons and their own use cases.
* SQL DB (SQL, Oracle, PostgreSQL, Aurora)
* NoSQL DB (DynamoDB, Cosmos DB, Snowflake, Google Big Query)

Microservices (and communication between them) vs monolith - learn the concept of microservices. Most likely you will be building right now a monolith. Or if your company is developing microservices then you are not aware of it. So read about it. Also, if there exist already microservices then how to set up a communication between different microservices/modules? Tools you can look into are: Kafka, ActiveMQ, RabbitMQ, Kafka Connect.

Logging - if you are developing a web application then most likely you wish to have logs for different events and actions. So you can learn about logging libraries. How the log events can be modified (appenders). Then where the logs will be stored (log files or streamed directly to somewhere). Then what can be done with these logs (log analysis, statistics, alerts, etc). Tools that you can look into are: Filebeat, ELK stack (Elasticsearch, Logstash, Kibana) and Splunk/Humio.

Monitoring of the system for different metrics (can be combined with logging) - you wish to see if your application is using system resources normally or lagging back in performance or just wasting resources for nothing. Or you wish to make analysis on some events. Or you want to see the health state of your database and its connections. So you need monitoring. Tools that you can look into are: Micrometer, Prometheus and Grafana.

AWS:

* https://github.com/localstack/localstack

Logging - if you are developing a web application then most likely you wish to have logs for different events and actions. So you can learn about logging libraries. How the log events can be modified (appenders). Then where the logs will be stored (log files or streamed directly to somewhere). Then what can be done with these logs (log analysis, statistics, alerts, etc). Tools that you can look into are: Filebeat, ELK stack (Elasticsearch, Logstash, Kibana) and Splunk/Humio.

Monitoring of the system for different metrics (can be combined with logging) - you wish to see if your application is using system resources normally or lagging back in performance or just wasting resources for nothing. Or you wish to make analysis on some events. Or you want to see the health state of your database and its connections. So you need monitoring. Tools that you can look into are: Micrometer, Prometheus and Grafana.

CI/CD (Continuous Delivery and Continuous Integration) - it is a concept of automatizing the process of building a project, running tests automatically, running different checks on the software, deploying the software to different environments and also releasing it to production. Tools you can look into are: Github Actions / Jenkins / Teamcity. And from the checks side you can implement Sonar check, OWASP check and also integration with Upsource.

Microservices (and communication between them) vs monolith - learn the concept of microservices. Most likely you will be building right now a monolith. Or if your company is developing microservices then you are not aware of it. So read about it. Also, if there exist already microservices then how to set up a communication between different microservices/modules? Tools you can look into are: Kafka, ActiveMQ, RabbitMQ, Kafka Connect.

Orchestration and deployment methods - some companies are just dropping the application to client server and running it there. Others are using virtual machines. Third ones are using Docker. So you can look into how the web application be deployed and run in the client side. Also different methods require different means for maintenance. Don't know from the virtual machine side but from Docker side you can look into: Docker itself, Kubernetes, Docker Swarm.

Project management - right now you are simply doing the tasks you are given. But learn what happens behind the scenes. How it is decided which tasks the team is working on? How are the tasks itself created? Etc. Don't be just the person who is picking tasks but try to become the person who creates tasks and makes decisions what to work on and when.
* Jira
* Github Issues

## Refrences

* http://www.aosabook.org/en/distsys.html
* https://fabrizio2210.medium.com/how-i-get-a-job-at-google-as-sre-83d44aef7859
* http://highscalability.com/all-time-favorites/
* https://aws.amazon.com/architecture/well-architected
* https://cloud.google.com/architecture/framework
* https://sre.google/workbook/non-abstract-design/
* https://docs.gitlab.com/ee/administration/reference_architectures/
* https://github.com/codeaprendiz/devops-essentials
* https://www.reddit.com/r/devops/comments/qsg5eq/ideas_for_a_side_project_blog_tutorial_showcasing/
* https://www.reddit.com/r/devops/comments/r0hsyk/it_infrastructure_vs_devops/
* https://www.udemy.com/course/docker-mastery/
* https://www.udemy.com/course/learn-devops-infrastructure-automation-with-terraform/
* https://www.udemy.com/course/jenkins-from-zero-to-hero/
* https://www.reddit.com/r/devops/comments/t2k58r/how_to_become_a_devops_engineer_in_2022/?utm_source=share&utm_medium=ios_app&utm_name=iossmf
* https://opengitops.dev/
* https://github.com/bregman-arie/devops-exercises

## Literature

## References

### DevOps
1. Kim, G., Behr, K., & Spafford, G. *The Phoenix Project: A Novel about IT, DevOps, and Helping Your Business Win*.
2. Kim, G., Debois, P., Willis, J., & Humble, J. *The DevOps Handbook: How to Create World-Class Agility, Reliability, and Security in Technology Organizations*.
3. Davis, J. & Daniels, K. *Effective DevOps: Building a Culture of Collaboration, Affinity, and Tooling at Scale*.
4. Beyer, B., Jones, C., Petoff, J., & Murphy, N. R. *Site Reliability Engineering: How Google Runs Production Systems*.

### Infrastructure as Code
5. Brikman, Y. *Terraform: Up & Running: Writing Infrastructure as Code*.
6. Morris, S. *Terraform in Action*.
7. Manning Publishing. *Terraform and AWS* (4 part LiveProject).
8. Geerling, J. *Ansible for DevOps: Server and Configuration Management for Humans*.

### SysAdmin
9. Nemeth, E., Snyder, G., Hein, T. R., & Whaley, B. *UNIX and Linux System Administration Handbook*.
10. van Vugt, S. *Red Hat RHCSA 8 Cert Guide: EX200 (Certification Guide)*.
11. Ward, B. *How Linux Works, 3rd Edition: What Every Superuser Should Know*.

### Git
12. Chacon, S. & Straub, B. *Pro Git*.
13. Loeliger, J. & McCullough, M. *Version Control with Git, 3rd Edition*.

### Containers
14. Kane, S. & Matthias, K. *Docker: Up & Running: Shipping Reliable Containers in Production, 2nd Edition*.
15. Moulton, I. & Moulton, D. *Docker in Practice, Second Edition*.
16. Poulton, E. *Docker in a Month of Lunches*.
17. Hightower, K., Burns, B., & Beda, J. *Kubernetes Up and Running*.
18. Arundel, J. & Domingus, J. *Cloud Native DevOps with Kubernetes: Building, Deploying, and Scaling Modern Applications in the Cloud*.
