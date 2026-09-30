resource "aws_iam_role_policy" "terraform_policy" {
  name = "terraform_policy"
  role = aws_iam_role.terraform_githubrole.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "VpcPolicy"
        Action = [
          "ec2:AssociateVpcCidrBlock",
          "ec2:CreateDefaultVpc",
          "ec2:CreateVpc",
          "ec2:DeleteVpc",
          "ec2:ModifyVpcAttribute",
          "ec2:DescribeVpcAttribute",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "DescribeAccountAttributes"
        Action = [
          "ec2:DescribeAccountAttributes",
          "ec2:CreateTags",
          "ec2:DescribeVpcs",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeAddresses",
          "ec2:DescribeAddressesAttribute",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeNatGateways",
          "ec2:DescribeRouteTables",
          "ec2:DescribeVpcEndpoints",
          "ec2:DescribePrefixLists",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeNetworkAcls",
          "ec2:DescribeAvailabilityZones",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "InternetGateway"
        Action = [
          "ec2:AttachInternetGateway",
          "ec2:CreateInternetGateway",
          "ec2:DeleteInternetGateway",
          "ec2:DetachInternetGateway",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "ElasticIpAddress"
        Action = [
          "ec2:AllocateAddress",
          "ec2:ReleaseAddress",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "NatGateways"
        Action = [
          "ec2:CreateNatGateway",
          "ec2:DeleteNatGateway",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "RouteTable"
        Action = [
          "ec2:CreateRoute",
          "ec2:CreateRouteTable",
          "ec2:AssociateRouteTable",
          "ec2:DeleteRouteTable",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "Endpoints"
        Action = [
          "ec2:DeleteVpcEndpoints",
          "ec2:CreateVpcEndpoint",
          "ec2:AcceptVpcEndpointConnections",
          "ec2:ModifyVpcEndpoint",

        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "SecurityGroups"
        Action = [
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "Subnets"
        Action = [
          "ec2:DeleteSubnet",
          "ec2:CreateSubnet",
          "ec2:AssociateSubnetCidrBlock",
          "ec2:DisassociateVpcCidrBlock",
          "ec2:ModifySubnetAttribute",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "Elasticloadbalancer"
        Action = [
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:DescribeTags",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "ListenerPolicy"
        Action = [
          "elasticloadbalancing:AddListenerCertificates",
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeListenerAttributes",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "TargetGroup"
        Action = [
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "ApiGatewaysRouteManagement"
        Action = [
          "apigateway:GET",
          "apigateway:POST",
          "apigateway:DELETE",
          "apigateway:PUT",
        ]
        Effect   = "Allow"
        Resource = "*"
      },

      {
        Sid = "DynamodbTables"
        Action = [
          "dynamodb:CreateTable",
          "dynamodb:GetItem",
          "dynamodb:DeleteItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteTable",
          "dynamodb:ListTables",
          "dynamodb:TagResource",
          "dynamodb:DescribeTable",
          "dynamodb:DescribeContinuousBackups",
          "dynamodb:DescribeTimeToLive",
          "dynamodb:ListTagsOfResource",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "DunamoDbStream"
        Action = [
          "dynamodb:ListTagsOfResource",
        ]
        Effect   = "Allow"
        Resource = "*"

      },
      {
        Sid = "Lambda"
        Action = [
          "lambda:CreateFunction",
          "lambda:DeleteFunction",
          "lambda:GetFunction",
          "lambda:UpdateFunctionCode",
          "lambda:TagResource",
          "lambda:ListVersionsByFunction",
          "lambda:GetFunctionCodeSigningConfig",
          "lambda:AddPermission",
          "lambda:GetPolicy",
          "lambda:RemovePermission",

        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "EccService"
        Action = [
          "ecs:TagResource",
          "ecs:CreateService",
          "ecs:DeleteService",
          "ecs:DescribeServices",
          "ecs:UpdateService",
          "ecs:ListServiceDeployments",
          "ecs:DescribeServiceDeployments"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "EcsCluster"
        Action = [
          "ecs:CreateCluster",
          "ecs:DeleteCluster",
          "ecs:DescribeClusters",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "EcsTaskDefinition"
        Action = [
          "ecs:DescribeTaskDefinition",
          "ecs:DeleteTaskDefinitions",
          "ecs:DeregisterTaskDefinition",
          "ecs:RegisterTaskDefinition",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "Route53"
        Action = [
          "route53:GetHostedZone",
          "route53:ListHostedZones",
          "route53:ListTagsForResource",
          "route53:ChangeResourceRecordSets",
          "route53:GetChange",
          "route53:ListResourceRecordSets",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "CloudFront"
        Action = [
          "cloudfront:DeleteOriginAccessControl",
          "cloudfront:CreateDistribution",
          "cloudfront:GetDistribution",
          "cloudfront:CreateCachePolicy",
          "cloudfront:CreateOriginAccessControl",
          "cloudfront:DeleteCachePolicy",
          "cloudfront:DeleteDistribution",
          "cloudfront:GetDistribution",
          "cloudfront:GetOriginAccessControl",
          "cloudfront:GetCachePolicy",
          "cloudfront:TagResource",
          "cloudfront:ListTagsForResource",
          "cloudfront:UpdateDistribution",

        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "CertificateManager"
        Action = [
          "acm:DeleteCertificate",
          "acm:ListCertificates",
          "acm:DescribeCertificate",
          "acm:ListTagsForCertificate",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "CertificateManagerRequest"
        Action = [
          "acm:RequestCertificate",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "TfStateBucket"
        Action = [
          "s3:ListBucket",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::orema-tfstate-bucket-9250"
      },
      {
        Sid = "TfStateObject"
        Action = [
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetObject",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::orema-tfstate-bucket-9250/*"
      },
      {
        Sid = "FontendS3object"
        Action = [
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetObject",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "FrontendBucket"
        Action = [
          "s3:CreateBucket",
          "s3:PutBucketOwnershipControls",
          "s3:PutBucketVersioning",
          "s3:DeleteBucket",
          "s3:DeleteBucketPolicy",
          "s3:PutBucketPublicAccessBlock",
          "s3:GetBucketPolicy",
          "s3:ListBucket",
          "s3:GetBucketPublicAccessBlock",
          "s3:GetBucketTagging",
          "s3:GetBucketAcl",
          "s3:GetBucketCORS",
          "s3:GetBucketWebsite",
          "s3:GetBucketVersioning",
          "s3:GetAccelerateConfiguration",
          "s3:GetBucketRequestPayment",
          "s3:GetBucketLogging",
          "s3:GetLifecycleConfiguration",
          "s3:GetReplicationConfiguration",
          "s3:GetEncryptionConfiguration",
          "s3:GetBucketObjectLockConfiguration",
          "s3:PutBucketTagging",
          "s3:GetBucketOwnershipControls",
          "s3:PutBucketPolicy",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "SecretManager"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DeleteSecret",
          "secretsmanager:ListSecrets",
          "secretsmanager:CreateSecret",
          "secretsmanager:TagResource",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "Rds"
        Action = [
          "rds:CreateDBInstance",
          "rds:AddTagsToResource",
          "rds:DeleteDBSubnetGroup",
          "rds:CreateDBSubnetGroup",
          "rds:ModifyDBInstance",
          "rds:DescribeDBSubnetGroups",
          "rds:ListTagsForResource",
          "rds:DescribeDBInstances",
          "rds:DeleteDBInstance",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "KMS"
        Action = [
          "kms:DescribeKey",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "Cognito"
        Action = [
          "cognito-idp:AdminCreateUser",
          "cognito-idp:DeleteUserPool",
          "cognito-idp:DescribeUserPool",
          "cognito-idp:GetUserPoolMfaConfig",
          "cognito-idp:CreateUserPoolClient",
          "cognito-idp:DescribeUserPoolClient"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "CognitoCreateUser"
        Action = [
          "cognito-idp:CreateUserPool",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "CloudWatch"
        Action = [
          "cloudwatch:DeleteAlarms",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:TagResource",
          "cloudwatch:PutMetricAlarm",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "CloudWatchListTags"
        Action = [
          "CloudWatch:ListTagsForResource"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "LogsGroup"
        Action = [
          "logs:CreateLogGroup",
          "logs:TagResource",
          "logs:DescribeLogGroups",
          "logs:ListTagsForResource",
          "logs:DeleteLogGroup",
          "logs:PutRetentionPolicy",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "SNS"
        Action = [
          "sns:CreateTopic",
          "sns:TagResource",
          "sns:DeleteTopic",
          "SNS:SetTopicAttributes",
          "SNS:GetTopicAttributes",
          "SNS:ListTagsForResource",
          "SNS:Subscribe",
          "SNS:GetSubscriptionAttributes",
          "SNS:Unsubscribe",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "SQS"
        Action = [
          "sqs:CreateQueue",
          "sqs:DeleteQueue",
          "sqs:GetQueueAttributes",
          "sqs:listqueuetags",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "ECR"
        Action = [
          "ecr:CreateRepository",
          "ecr:TagResource",
          "ecr:DeleteRepository",
          "ecr:GetAuthorizationToken",
          "ecr:UntagResource",
          "ecr:DescribeRepositories",
          "ecr:ListTagsForResource",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "IAM"
        Action = [
          "iam:CreateRole",
          "iam:AttachRolePolicy",
          "iam:CreatePolicy",
          "iam:DeleteRole",
          "iam:DeletePolicy",
          "iam:DetachRolePolicy",
          "iam:GetRolePolicy",
          "iam:GetRole",
          "iam:GetPolicy",
          "iam:PutRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:ListInstanceProfilesForRole",
          "iam:ListInstanceProfilesForRole",
          "iam:ListEntitiesForPolicy",
          "iam:TagRole",

        ]
        Effect   = "Allow"
        Resource = "*"
      },

      {
        Sid    = "PassOnlylambdaApplicationRole"
        Effect = "Allow"

        Action = [
          "iam:PassRole"
        ]

        Resource = "*"

        Condition = {
          StringEquals = {
            "iam:PassedToService" = "lambda.amazonaws.com"
          }
        }
      },

      {
        Sid    = "PassOnlyECSApplicationRole"
        Effect = "Allow"

        Action = [
          "iam:PassRole"
        ]

        Resource = "*"

        Condition = {
          StringEquals = {
            "iam:PassedToService" = ["ecs-tasks.amazonaws.com", "ecs.amazonaws.com"]
          }
        }
      },

    ]
  })
}