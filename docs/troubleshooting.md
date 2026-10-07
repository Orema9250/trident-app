# CloudTask — Troubleshooting Journal

This document records the major deployment, infrastructure, application, IAM, networking, and CI/CD issues encountered while building CloudTask.

The purpose is not to list errors for the sake of listing them. Each incident documents how I investigated the failure, identified the broken layer, applied a controlled fix, and verified the result.

The biggest lesson from the project was:

> **Do not assume that because an AWS resource is running, the application is working. Find the first broken boundary and investigate from there.**

---

# 1. ECS Tasks Failed Before the Container Started

## Symptom

The ECS service deployment failed because tasks could not start.

The ECS service showed deployment problems, while the stopped task information showed:

```text
TaskFailedToStart
ResourceInitializationError
```

At this stage there was no useful application exit code because the container had not actually reached the application startup phase.

## Investigation

I first checked the ECS service events:

```bash
aws ecs describe-services \
  --cluster cloudtask-cluster \
  --services backend \
  --region us-east-1
```

I then inspected stopped tasks:

```bash
aws ecs list-tasks \
  --cluster cloudtask-cluster \
  --service-name backend \
  --desired-status STOPPED \
  --region us-east-1
```

And examined the individual task:

```bash
aws ecs describe-tasks \
  --cluster cloudtask-cluster \
  --tasks <task-arn> \
  --region us-east-1
```

The important observation was that the failure occurred during ECS task initialization rather than inside the Node.js application.

## Root Cause

The failure was ultimately traced to infrastructure required by Fargate before the application container could start.

One instance involved the ECS task attempting to authenticate with ECR through a private VPC endpoint:

```text
GetAuthorizationToken
connection timed out
10.0.x.x:443
```

The task was in a private subnet, so its ability to reach AWS services depended on the VPC endpoint configuration and security groups.

## Resolution

I verified the required private connectivity for ECR, including:

```text
ECR API endpoint
ECR DKR endpoint
S3 gateway endpoint
```

I also checked that the endpoint security group allowed HTTPS traffic from the ECS task security group.

## Lesson

A Fargate task can fail before the application has any opportunity to log an error.

When a task shows:

```text
ResourceInitializationError
```

I learned to investigate:

```text
ECR
Secrets Manager
CloudWatch Logs
VPC endpoints
Security groups
IAM execution role
```

before debugging the application itself.

---

# 2. ECS Tasks Failed Because the CloudWatch Log Group Did Not Exist

## Symptom

Another ECS deployment failed with:

```text
TaskFailedToStart
ResourceInitializationError
```

The important error indicated that the `awslogs` configuration could not create a log stream because the configured CloudWatch log group did not exist.

## Investigation

The application container was not producing normal application logs because the failure happened during ECS initialization.

The task definition contained an `awslogs` configuration pointing to a CloudWatch log group.

I checked the ECS task definition and CloudWatch resources and discovered that the expected log group had not been created.

## Root Cause

The ECS task definition referenced a CloudWatch log group that Terraform had not provisioned.

Fargate therefore could not initialize the logging configuration correctly.

## Resolution

I changed the Terraform configuration so the log group was managed explicitly:

```text
Terraform
   ↓
CloudWatch Log Group
   ↓
ECS Task Definition
   ↓
Fargate Task
```

The log group was created before the ECS task needed it.

## Lesson

Logging infrastructure is part of the application's startup dependencies.

A container can fail before application startup simply because its logging destination is missing.

This also reinforced the value of managing supporting AWS resources through Terraform rather than assuming they already exist.

---

# 3. ECS Execution Role Could Not Read the Database Secret

## Symptom

The ECS task was able to progress further, but the application deployment had problems retrieving the database credentials stored in Secrets Manager.

## Investigation

I inspected the ECS task definition and separated the two IAM roles involved:

```text
ECS Execution Role
        ↓
ECS/Fargate infrastructure operations

ECS Task Role
        ↓
Application runtime permissions
```

The Secrets Manager permission had been attached to the task role rather than the execution role required to retrieve the secret during task initialization.

## Root Cause

The wrong IAM role had the permission.

The ECS execution process needed:

```text
secretsmanager:GetSecretValue
```

for the database secret.

Giving the permission only to the application task role did not solve the initialization requirement.

## Resolution

The permission was moved to the ECS execution role.

The task role remained responsible for permissions required by the running application.

## Lesson

Understanding the difference between:

```text
executionRoleArn
```

and:

```text
taskRoleArn
```

is important when troubleshooting ECS.

The execution role is used by ECS/Fargate to perform operations on behalf of the task.

The task role provides AWS permissions to the application itself.

---

# 4. ECS and ALB Were Healthy, but Database Health Returned 503

## Symptom

The main health endpoint returned successfully:

```text
/api/health
```

but:

```text
/api/db-health
```

returned:

```json
{
  "status": "unhealthy",
  "database": "disconnected"
}
```

The important distinction was:

```text
ALB → ECS → Node.js
```

was working.

But:

```text
ECS → RDS PostgreSQL
```

was failing.

## Investigation

I checked the ECS environment configuration, RDS endpoint, port, security groups, and CloudWatch logs.

The application was using:

```text
DB_HOST=<RDS endpoint>
DB_PORT=5432
DB_NAME=mydatabase
```

The CloudWatch logs eventually exposed the important PostgreSQL error:

```text
no pg_hba.conf entry ...
no encryption
```

## Root Cause

Network connectivity to RDS existed, but PostgreSQL rejected the connection because the client connection did not satisfy the database's encryption requirements.

This was an important distinction:

```text
TCP connectivity working
        ≠
PostgreSQL connection accepted
```

## Resolution

The database client configuration was updated to use SSL/TLS for the PostgreSQL connection.

After the change, the application could establish the database connection.

## Lesson

A database problem should not automatically be treated as a security-group problem.

The troubleshooting layers were:

```text
DNS
 ↓
Network route
 ↓
Security Group
 ↓
TCP 5432
 ↓
PostgreSQL authentication
 ↓
TLS/encryption
 ↓
Database/application credentials
```

The failure can occur at any of these boundaries.

---

# 5. Application Failed Because the PostgreSQL `tasks` Table Did Not Exist

## Symptom

The backend itself was reachable, but task operations returned database errors similar to:

```text
42P01: relation "tasks" does not exist
```

The API could therefore be reached, but operations that depended on the database schema failed.

## Investigation

The RDS instance itself was available.

The application could connect to PostgreSQL.

The problem was therefore no longer:

```text
ECS → RDS connectivity
```

Instead, it was:

```text
Application → PostgreSQL schema
```

I checked the database initialization process and the repository's:

```text
database/init.sql
```

file.

## Root Cause

The PostgreSQL database existed, but the application's required schema had not been initialized.

The RDS instance being:

```text
AVAILABLE
```

did not mean that application tables automatically existed.

## Resolution

The project included SQL for creating the required table:

```sql
CREATE TABLE IF NOT EXISTS tasks (...);
```

The database initialization process was then addressed so the application schema could be created.

During local Docker development, I also learned that PostgreSQL initialization scripts mounted into:

```text
/docker-entrypoint-initdb.d/
```

run when the database is initialized with a fresh data directory.

Existing persistent volumes therefore required resetting the local database when testing initialization changes.

## Lesson

This incident produced one of the clearest lessons from the project:

```text
RDS = AVAILABLE
        ≠
Application Database = READY
```

Infrastructure provisioning and application schema management are two different concerns.

For a production environment, I would use a proper database migration mechanism rather than relying solely on container initialization scripts.

---

# 6. Lambda Worked, but API Gateway Returned Errors

## Symptom

The Lambda function could be invoked directly and returned a successful response.

However, requests through API Gateway failed.

This initially made it tempting to debug the Lambda code itself.

## Investigation

I tested the Lambda independently and confirmed that the function was capable of executing.

I then checked:

```text
API Gateway
 ↓
Integration
 ↓
Lambda
```

The API Gateway integration pointed to the correct Lambda function.

I also checked the Lambda resource policy:

```bash
aws lambda get-policy \
  --function-name lambda-function \
  --region us-east-1
```

The result indicated that the expected API Gateway invocation permission was missing.

## Root Cause

API Gateway needed permission to invoke the Lambda function.

The Lambda function itself worked, but the service-to-service authorization boundary was incomplete.

## Resolution

The Lambda resource-based permission was configured so API Gateway could invoke the function.

## Lesson

When:

```text
Direct Lambda invocation = works
API Gateway invocation = fails
```

the Lambda application code may not be the problem.

The investigation should move toward:

```text
API Gateway route
 ↓
Integration
 ↓
Stage
 ↓
Lambda invocation permission
```

---

# 7. API Gateway Routes and Stage Configuration

## Symptom

Some serverless endpoints returned unexpected:

```text
404
```

or other API errors even though Lambda itself was functional.

## Investigation

I inspected the HTTP API configuration and its routes.

The project used an API Gateway stage:

```text
/dev
```

with routes such as:

```text
GET    /activities
POST   /activities
GET    /activities/{id}
DELETE /activiities/{id}
```

The route configuration had to match the actual paths being called by the frontend.

## Root Cause

The problem was in the API Gateway routing/stage layer rather than the Lambda function itself.

There were also route naming details that needed to match exactly.

## Resolution

The API Gateway routes and frontend endpoint configuration were aligned.

## Lesson

A successful Lambda deployment does not prove that the HTTP API is correctly configured.

For API Gateway problems I learned to verify:

```text
URL
 ↓
Stage
 ↓
HTTP method
 ↓
Route
 ↓
Integration
 ↓
Lambda permission
 ↓
Lambda
```

---

# 8. Frontend Had a Stale Serverless API URL

## Symptom

The frontend contained environment variables for both application backends.

One of the values pointed to an API Gateway URL that was no longer the intended endpoint.

The frontend configuration contained:

```text
VITE_BACKEND_URL=https://api.orema-devops.xyz
```

and:

```text
VITE_SERVERLESS_URL=https://8v8dht9a51.execute-api.us-east-1.amazonaws.com/dev
```

The issue was determining whether the stale value in the local `.env` file was actually being used by the current deployment.

## Investigation

I traced where the frontend environment variables were being supplied during the GitHub Actions deployment.

The important distinction was between:

```text
local .env
```

and:

```text
GitHub Actions deployment environment
```

## Lesson

When debugging frontend API failures, check both:

```text
What value exists locally?
```

and:

```text
What value was actually injected during the build?
```

A correct local `.env` file does not guarantee that the deployed frontend was built with the same values.

---

# 9. DynamoDB / Serverless Data Layer

## Symptom

The serverless application depended on the DynamoDB table:

```text
cloudtask-activities
```

Some failures initially appeared to be application or Lambda problems.

## Investigation

I checked the Lambda configuration and confirmed that the function used:

```text
ACTIVITY_TABLE
```

with the expected table name.

The Lambda code used the AWS SDK DynamoDB document client and operations including:

```text
PutCommand
ScanCommand
GetCommand
UpdateCommand
DeleteCommand
```

## Root Cause / Lesson

The serverless application has several separate dependencies:

```text
API Gateway
    ↓
Lambda
    ↓
IAM permissions
    ↓
DynamoDB
```

A Lambda function can be running correctly while still failing when it attempts to access DynamoDB.

The investigation therefore needs to distinguish:

```text
Lambda execution problem
```

from:

```text
Lambda → DynamoDB authorization/configuration problem
```

---

# 10. GitHub Actions Failed Because of Missing IAM Permissions

## Symptom

The application worked from AWS, but GitHub Actions deployments failed with AWS `AccessDenied` errors.

The issue appeared after moving toward a least-privilege GitHub OIDC role.

## Investigation

Instead of giving the GitHub role broad administrator permissions, I used the deployment errors and CloudTrail activity to identify the exact AWS actions required.

The process was:

```text
GitHub Actions
      ↓
OIDC
      ↓
IAM Role
      ↓
AWS API call
      ↓
AccessDenied
      ↓
Identify required action
      ↓
Add narrowly scoped permission
      ↓
Run workflow again
```

This exposed several missing permissions during different stages of the project.

## Examples

The GitHub deployment role required permissions for operations involving:

```text
ECR
ECS
Lambda
IAM PassRole
S3
Route 53
CloudFront
```

Rather than solving these with:

```text
Action: "*"
Resource: "*"
```

I worked toward service-specific and resource-specific permissions.

## Lesson

Least privilege is iterative.

A practical deployment role often starts with the permissions necessary to perform the deployment and is then refined using actual AWS activity and Access Analyzer.

---

# 11. ECS Deployment Failed Because `iam:PassRole` Was Missing

## Symptom

GitHub Actions could interact with ECS but failed when attempting operations involving the ECS task definition.

The deployment role received an IAM access-denied error involving:

```text
iam:PassRole
```

## Root Cause

ECS task definitions reference IAM roles.

When GitHub Actions registered or deployed a task definition, the GitHub OIDC role needed permission to pass the ECS roles to the ECS service.

## Resolution

The permission was scoped to the specific ECS roles rather than allowing arbitrary role passing.

The policy used the relevant roles:

```text
ecsexecution-role
ecstask-role
```

and restricted the service through:

```text
iam:PassedToService
```

## Lesson

`iam:PassRole` does not mean:

> "The GitHub role can assume any IAM role."

It means the caller can pass a specified role to an AWS service.

This is an important IAM concept when automating ECS deployments.

---

# 12. GitHub Actions Could Not Describe the ECS Service

## Symptom

A deployment workflow reached the ECS stage but received an `AccessDenied` error for an ECS describe operation.

The workflow needed to inspect the cluster/service before or after deployment.

## Investigation

I checked the exact AWS CLI operation being performed and matched it against the IAM policy.

The required permission was related to:

```text
ecs:DescribeServices
```

## Resolution

The ECS permissions were refined to include the required describe operation and scoped to the relevant ECS resources where possible.

## Lesson

Least-privilege policies must account for both:

```text
write actions
```

and:

```text
read/describe actions
```

A deployment system often needs to read the current state before it can safely update it.

---

# 13. Lambda Deployment Failed Because `UpdateFunctionCode` Was Not Allowed

## Symptom

The GitHub Actions serverless deployment reached Lambda but failed with an IAM access-denied error for:

```text
lambda:UpdateFunctionCode
```

## Root Cause

The OIDC role could authenticate to AWS but did not have permission to update the Lambda function code.

## Resolution

The Lambda deployment policy was updated to allow the required function update operation against the specific Lambda function.

## Lesson

Authentication and authorization are separate:

```text
OIDC authentication = Who is calling?
IAM policy           = What can they do?
```

Successfully assuming the GitHub OIDC role does not automatically provide deployment permissions.

---

# 14. Lambda Build Failed Because `npm ci` Could Not Find a Lock File

## Symptom

The serverless GitHub Actions workflow attempted:

```bash
npm ci --omit=dev
```

but failed because the Lambda directory did not contain the expected `package-lock.json`.

## Root Cause

`npm ci` requires a lock file.

The workflow was running the command against a directory where the expected dependency lock file was not available.

## Lesson

CI builds are more strict than local development.

Before using:

```bash
npm ci
```

the repository should contain the dependency lock file in the directory from which the command is executed.

This incident also reinforced the importance of making the CI workflow's working directory explicit.

---

# 15. ECR Image Tagging and Immutable Tags

## Symptom

The ECS deployment used an ECR repository configured with immutable image tags.

The initial Terraform configuration referenced:

```text
v1
```

while later CI/CD deployments were intended to use unique Git commit SHA tags.

This created an important deployment dependency: the initial image referenced by Terraform had to exist before ECS could start successfully.

## Root Cause

Immutable ECR tags cannot simply be overwritten.

Using the same:

```text
v1
```

tag for repeated deployments conflicts with immutable tag behavior.

## Resolution

The initial `v1` image was treated as a bootstrap image.

Subsequent GitHub Actions deployments use unique commit-based image tags.

Conceptually:

```text
Initial infrastructure
        ↓
ecr:v1

Later CI/CD
        ↓
ecr:<commit-sha>
```

## Lesson

Immutable image tags work well with reproducible deployments, but the infrastructure and application deployment workflow must agree on the image lifecycle.

---

# 16. Terraform and ECS Deployment Ownership

## Symptom

The project used Terraform to manage ECS infrastructure while GitHub Actions also needed to update the ECS task definition with newly built container images.

This created the possibility of two systems attempting to manage the same ECS state.

## Problem

Terraform wanted to manage:

```text
ECS task definition
ECS service
```

while CI/CD needed to update:

```text
container image
```

for each deployment.

## Resolution

The deployment workflow was adjusted so Terraform handled infrastructure while the application deployment workflow handled the new container image.

The approach considered the ownership boundary between:

```text
Terraform
```

and:

```text
GitHub Actions
```

rather than allowing both systems to continuously overwrite each other's state.

## Lesson

Infrastructure as Code works best when resource ownership is clearly defined.

A useful principle is:

```text
Terraform → infrastructure lifecycle

CI/CD → application artifact deployment
```

---

# 17. Terraform IAM Policy Size Limit

## Symptom

The GitHub OIDC IAM policy became too large as more least-privilege permissions were added.

AWS inline policy size limits became a constraint.

## Investigation

The policy contained permissions across multiple AWS services:

```text
ECS
ECR
Lambda
IAM
S3
Route 53
CloudFront
```

Trying to keep everything in one large policy made it difficult to maintain and eventually approached the policy size limit.

## Resolution

The permissions were separated into smaller policy documents grouped by responsibility/service.

For example:

```text
compute.json
storage.json
dns.json
serverless.json
```

The exact grouping can evolve, but the important principle is to avoid one enormous IAM document.

## Lesson

Least privilege is not only about restricting permissions.

It also requires structuring policies so they remain maintainable.

---

# 18. Route 53 and S3 Permissions Appeared During Least-Privilege Refinement

## Symptom

GitHub Actions deployments encountered additional `AccessDenied` errors involving AWS APIs that were not initially obvious.

Examples included operations such as:

```text
route53:ListTagsForResource
s3:GetBucketRequestPayment
```

## Investigation

Instead of adding broad Route 53 or S3 permissions, I used the denied API operation to determine what the deployment process was actually attempting to do.

## Lesson

Some AWS provider operations perform additional read or metadata calls that are easy to overlook when writing IAM policies manually.

This is one reason CloudTrail and actual deployment failures are useful when refining least-privilege policies.

---

# 19. RDS Provisioning Capacity Problems

## Symptom

Terraform attempts to create the RDS PostgreSQL instance encountered AWS capacity-related problems for the selected instance configuration in `us-east-1`.

The issue appeared while working with:

```text
db.t4g.micro
```

and storage configurations such as:

```text
gp2
gp3
```

## Investigation

The important observation was that the Terraform configuration could be syntactically valid while AWS still rejected the requested infrastructure because of regional capacity or configuration availability.

## Lesson

Terraform validates configuration syntax and provider requirements, but it cannot guarantee that AWS has capacity for a particular resource configuration in a particular region.

This is an important distinction between:

```text
Terraform configuration validity
```

and:

```text
AWS resource provisioning availability
```

---

# 20. Secrets Manager / KMS Configuration Issues

## Symptom

Database secret provisioning and access involved additional errors around encryption/KMS configuration.

The project used:

```text
RDS
 ↓
Secrets Manager
 ↓
ECS
```

and the secret was managed by AWS rather than hard-coded into the application.

## Investigation

I checked:

```text
Secret
KMS configuration
IAM permissions
ECS execution role
RDS secret configuration
```

The investigation showed that secret access involves more than simply creating a secret.

## Lesson

When debugging Secrets Manager failures, check the entire chain:

```text
Secret exists
       ↓
Correct ARN
       ↓
Correct encryption configuration
       ↓
Caller has permission
       ↓
Correct IAM role
       ↓
Service can reach Secrets Manager
```

---

# 21. Terraform / ECS Provider Configuration Issue

## Symptom

Some ECS deployment configuration changes produced Terraform/provider errors around ECS deployment configuration.

One issue involved trying to use configuration that was not supported by the provider version being used.

## Investigation

I compared the Terraform resource configuration against the AWS provider behavior and the current ECS deployment configuration supported by the project.

## Resolution

The ECS service was changed from the problematic deployment configuration to a supported rolling deployment approach.

## Lesson

Terraform resource syntax and AWS service capabilities evolve over time.

When a configuration fails even though the underlying AWS concept exists, check:

```text
Terraform version
AWS provider version
resource schema
supported arguments
```

rather than assuming the AWS service itself is unavailable.

---

# 22. Local Docker Testing Helped Separate Application Problems from AWS Problems

## Approach

Before relying entirely on AWS, I tested the Node.js backend locally using Docker and Docker Compose.

The local environment allowed me to validate:

```text
Application startup
Container networking
PostgreSQL connectivity
Health endpoints
Environment variables
Database initialization
```

## Important distinction

The application exposed separate health checks:

```text
/api/health
```

for application health and:

```text
/api/db-health
```

for database connectivity.

This distinction proved useful later in AWS.

For example:

```text
/api/health = healthy
/api/db-health = unhealthy
```

immediately indicated that the application container was running while the database integration was failing.

## Lesson

Local container testing reduced the number of variables involved when debugging AWS deployments.

It helped establish whether a problem was:

```text
Application
```

or:

```text
AWS infrastructure
```

before making changes in the cloud.

---

# 23. The Most Useful Troubleshooting Pattern

Across the project, the most reliable approach became identifying the first failing boundary.

For the ECS application:

```text
Internet
   ↓
Route 53
   ↓
ALB
   ↓
Target Group
   ↓
ECS Service
   ↓
ECS Task
   ↓
Container
   ↓
Node.js Application
   ↓
RDS
   ↓
PostgreSQL
```

For the serverless application:

```text
Client
   ↓
API Gateway
   ↓
Route
   ↓
Integration
   ↓
Lambda
   ↓
IAM
   ↓
DynamoDB
```

For CI/CD:

```text
GitHub
   ↓
GitHub Actions
   ↓
OIDC
   ↓
IAM Role
   ↓
AWS API
   ↓
AWS Resource
```

Instead of changing multiple components at once, I learned to identify the first layer where the expected behavior stopped.

---

# 24. General Lessons From the Project

## A running resource is not necessarily a working application

```text
ECS Task = RUNNING
        ≠
Application = HEALTHY
```

and:

```text
RDS = AVAILABLE
        ≠
Application Database = READY
```

AWS reports the state of the infrastructure resource, not necessarily the health of the entire application.

---

## Errors should determine the next investigation

For example:

```text
ResourceInitializationError
```

suggests looking at infrastructure initialization.

Whereas:

```text
42P01: relation does not exist
```

suggests the database connection succeeded and the next layer to investigate is the schema.

Likewise:

```text
AccessDenied
```

points toward IAM authorization rather than application networking.

---

## Logs are evidence

The project relied heavily on:

```text
CloudWatch Logs
ECS Service Events
Terraform Errors
AWS CLI output
CloudTrail
IAM Access Analyzer
```

rather than repeatedly changing configuration and hoping the problem disappeared.

---

## Least privilege requires iteration

The GitHub OIDC deployment role was not created perfectly on the first attempt.

The permissions evolved as actual deployment operations exposed what the workflow required.

The process became:

```text
Deploy
 ↓
AccessDenied
 ↓
Identify API action
 ↓
Determine resource
 ↓
Add required permission
 ↓
Test again
 ↓
Refine
```

This provided practical experience with IAM beyond simply attaching AWS managed policies.

---

# 25. Final Takeaway

The most valuable part of CloudTask was not successfully provisioning ECS, Lambda, RDS, or Terraform.

It was learning how the services interact when something goes wrong.

A failure could occur at several different boundaries:

```text
Networking
IAM
AWS service configuration
Container initialization
Application configuration
Database connectivity
Database schema
API integration
CI/CD permissions
```

The project changed my troubleshooting approach from:

> "What configuration should I change?"

to:

> "What is the first component that is demonstrably failing, and what evidence proves it?"

That mindset is now one of the main outcomes of the project.

CloudTask was intentionally built, broken, investigated, and fixed to develop practical cloud engineering skills rather than only following a deployment tutorial.
