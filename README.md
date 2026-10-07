# CloudTask

A cloud-native task management application built on AWS using **ECS Fargate, Lambda, API Gateway, RDS PostgreSQL, DynamoDB, S3, CloudFront, Terraform, Docker, and GitHub Actions**.

The goal of this project was not just to deploy an application, but to build and troubleshoot a realistic AWS environment using infrastructure as code and secure CI/CD.

## Architecture

![CloudTask Architecture](docs/architecture.png)

### How it works

There are two backend paths in the architecture.

**Containerized application**

```text
User
  ↓
Route 53
  ↓
Application Load Balancer
  ↓
ECS Fargate
  ↓
RDS PostgreSQL
```

The main Node.js/Express application runs inside Docker containers on ECS Fargate. The containers run in private subnets and are accessed through an internet-facing Application Load Balancer.

**Serverless application**

```text
Client
  ↓
API Gateway
  ↓
Lambda
  ↓
DynamoDB
```

Lambda handles lightweight serverless operations while DynamoDB provides the serverless data store.

The frontend is delivered separately:

```text
User
  ↓
CloudFront
  ↓
S3
```

---

## What I built

### Application

* Node.js / Express backend
* Dockerized application
* Task management API
* Application and database health endpoints
* Lambda-based serverless API
* DynamoDB-backed operations
* PostgreSQL-backed application data

### AWS Infrastructure

* VPC
* Public, private application, and database subnets
* Application Load Balancer
* ECS Fargate
* ECR
* RDS PostgreSQL
* Lambda
* API Gateway
* DynamoDB
* S3
* CloudFront
* Route 53
* Secrets Manager
* CloudWatch

### DevOps & Security

* Terraform Infrastructure as Code
* Docker
* GitHub Actions
* GitHub OIDC federation
* IAM least privilege
* CloudTrail
* IAM Access Analyzer

---

## CI/CD

GitHub Actions handles the deployment workflow.

```text
GitHub
   ↓
GitHub Actions
   ↓
AWS OIDC
   ↓
IAM Role
   ↓
Terraform / ECR
   ↓
AWS Infrastructure
   ↓
ECS / Lambda
```

I used **GitHub OIDC instead of storing long-lived AWS access keys in GitHub**.

Terraform manages the AWS infrastructure, while Docker images are built and pushed to ECR before being deployed to ECS.

---

## Security

Security was considered as part of the architecture rather than added afterwards.

Some of the main controls include:

* ECS workloads running in private subnets
* RDS isolated in database subnets
* Database credentials stored in AWS Secrets Manager
* IAM roles instead of hard-coded AWS credentials
* GitHub Actions authenticated using OIDC
* Least-privilege IAM policies
* Security groups controlling communication between tiers
* CloudWatch logging for application troubleshooting
* CloudTrail used to investigate AWS API activity

---

## Troubleshooting

This project involved several real deployment and configuration problems.

One of the most useful lessons was learning to **find the first broken layer instead of changing random configuration**.

For example, when the backend was unavailable I worked through:

```text
ALB
 ↓
Target Group
 ↓
ECS Task
 ↓
Container
 ↓
Application
 ↓
Database
```

Some of the issues I encountered included:

* ECS tasks running but the application not being healthy
* PostgreSQL connectivity and `pg_hba`/encryption issues
* ECS access to Secrets Manager
* Missing PostgreSQL application tables
* Lambda working directly while API Gateway returned errors
* API Gateway route and stage configuration problems
* CORS configuration
* Missing IAM permissions during Terraform deployment
* `iam:PassRole` requirements for ECS
* Route 53 and S3 API permissions
* Terraform IAM policy size limits
* ECS deployment/provider configuration issues

I used **CloudWatch logs, ECS service events, CloudTrail, Terraform errors, and IAM Access Analyzer** to investigate these problems instead of relying on trial and error.

---

## A lesson from the project

One of the biggest lessons was that a resource being "up" does not necessarily mean the application is working.

For example:

```text
ECS Service = RUNNING
        ≠
Application = HEALTHY
```

And:

```text
RDS Instance = AVAILABLE
        ≠
Application Database = READY
```

The database still needed the application's schema initialized before endpoints depending on those tables could work.

This changed how I approach cloud troubleshooting: **identify the failing boundary first, gather evidence, make one controlled change, and test again.**

---

## Infrastructure as Code

The AWS environment is provisioned with Terraform rather than manually creating each resource through the AWS Console.

The Terraform configuration manages resources such as:

```text
VPC
├── Subnets
├── Route Tables
├── Security Groups
│
├── ALB
│   └── Target Group
│
├── ECS
│   └── Fargate Service
│
├── RDS
│
├── Lambda
│
├── API Gateway
│
├── DynamoDB
│
├── S3
│
├── CloudFront
│
└── IAM
```

This allows the infrastructure to be reviewed, changed, and reproduced through code.

---

## Local Development

Before deploying to AWS, I tested the backend locally using Docker.

```text
Application code
      ↓
Docker
      ↓
Local testing
      ↓
Health checks
      ↓
ECR
      ↓
ECS Fargate
```

This helped separate application-level problems from AWS infrastructure problems.

---

## What this project demonstrates

This project gave me hands-on experience across several areas of cloud engineering:

| Area            | Experience                             |
| --------------- | -------------------------------------- |
| AWS Networking  | VPC, subnets, routing, security groups |
| Containers      | Docker, ECS Fargate                    |
| Load Balancing  | ALB, target groups, health checks      |
| Serverless      | Lambda, API Gateway                    |
| Databases       | RDS PostgreSQL, DynamoDB               |
| Storage         | S3                                     |
| CDN             | CloudFront                             |
| DNS             | Route 53                               |
| Secrets         | Secrets Manager                        |
| Monitoring      | CloudWatch                             |
| Infrastructure  | Terraform                              |
| CI/CD           | GitHub Actions                         |
| Cloud Security  | IAM, OIDC, least privilege             |
| Troubleshooting | CloudTrail, logs, service events       |

---

## Screenshots

### Application

![Application](docs/screenshots/application.png)

### ECS Fargate

![ECS](docs/screenshots/ecs.png)

### Healthy ALB Targets

![ALB Target Group](docs/screenshots/alb-targets.png)

### GitHub Actions

![GitHub Actions](docs/screenshots/github-actions.png)

### Lambda / API Gateway

![Serverless](docs/screenshots/serverless.png)

### CloudWatch

![CloudWatch](docs/screenshots/cloudwatch.png)

---

## Future Improvements

Some improvements I would make in a production environment include:

* Automated database migrations
* Automated integration testing
* More granular IAM policies
* Deployment approval/rollback gates
* More comprehensive monitoring and alerting
* Additional security hardening

---

## Tech Stack

**AWS:** ECS Fargate · ECR · ALB · Lambda · API Gateway · RDS PostgreSQL · DynamoDB · S3 · CloudFront · Route 53 · Secrets Manager · CloudWatch · VPC

**DevOps:** Terraform · Docker · GitHub Actions · GitHub OIDC · IAM · CloudTrail · IAM Access Analyzer

**Application:** Node.js · Express · PostgreSQL · DynamoDB

---

## Project Goal

This project was built to strengthen my practical understanding of **AWS infrastructure, containers, serverless architecture, Infrastructure as Code, CI/CD, IAM, and cloud troubleshooting**.

Rather than only following a deployment tutorial, I intentionally built, broke, investigated, and fixed different parts of the environment to understand how the services actually interact.
