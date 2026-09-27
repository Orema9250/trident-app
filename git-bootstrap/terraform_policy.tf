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
          "ec2:CreateTags",
          "ec2:DeleteVpc",
          "ec2:DescribeVpcs",
          "ec2:ModifyVpcAttribute",
          "ec2:DescribeVpcAttribute",
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
          "ec2:DescribeInternetGateways"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "ElasticIpAddress"
        Action = [
          "ec2:AllocateAddress",
          "ec2:ReleaseAddress",
          "ec2:DescribeAddresses",
          "ec2:DescribeAddressesAttribute"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "NatGateways"
        Action = [
          "ec2:CreateNatGateway",
          "ec2:DeleteNatGateway",
          "ec2:DescribeNatGateways"
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
          "ec2:DescribeRouteTables",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "Endpoints"
        Action = [
          "ec2:DeleteVpcEndpoints",
          "ec2:DescribeVpcEndpoints",
          "ec2:CreateVpcEndpoint",
          "ec2:AcceptVpcEndpointConnections",
          "ec2:ModifyVpcEndpoint"
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
          "ec2:DescribeSecurityGroups",
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
          "ec2:DescribeSubnets",
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
          "elasticloadbalancing:DeleteListener"
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
          "dynamodb:TagResource"
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
          "lambda:UpdateFunctionCode"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "ECS"
        Action = [
          "ecs:CreateCluster",
          "ecs:RegisterTaskDefinition",
          "ecs:TagResource",
          "ecs:CreateService",
          "ecs:DeleteCluster",
          "ecs:DeleteService",
          "ecs:DeleteTaskDefinitions",
          "ecs:DeregisterTaskDefinition",
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

        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "CertificateManager"
        Action = [
          "acm:DeleteCertificate",
          "acm:GetCertificate",
          "acm:ListCertificates",
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
          "secretsmanager:CreateSecret"
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
          "rds:DescribeDBSubnetGroups"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "Cognito"
        Action = [
          "cognito-idp:AdminCreateUser",
          "cognito-idp:DeleteUserPool",
          "cognito-idp:CreateUserPool"
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

        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "LogsGroup"
        Action = [
          "logs:CreateLogGroup",
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
          "ecr:DescribeRepositories"
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