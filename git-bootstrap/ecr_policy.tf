
resource "aws_iam_role_policy" "github_ecr_role_policy" {
  role = aws_iam_role.ecr_githubrole.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EcrAuthorization"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
        ]
        Resource = "*"
      },

      {
        Sid    = "ecrpushpolicy"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
        ]

        Resource = "*"
      },
      {
        Sid = "EcrServiceforEcr"
        Action = [
          "ecs:TagResource",
          "ecs:DescribeServices",
          "ecs:UpdateService",
          "ecs:ListServiceDeployments",
          "ecs:DescribeServiceDeployments",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:ecs:us-east-1:090243701151:service/cloudtask-cluster/backend"
      },
      {
        Sid = "EcsTaskDefinitionforEcr"
        Action = [
          "ecs:DescribeTaskDefinition",
          "ecs:DeregisterTaskDefinition"
        ]
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Sid = "RegisterTaskDefinition"
        Action = [
          "ecs:RegisterTaskDefinition"
        ]
        Effect   = "Allow",
        Resource = "arn:aws:ecs:us-east-1:090243701151:task-definition/ecs-task:*"
      },
      {
        Sid    = "PassOnlyECSApplicationRole"
        Effect = "Allow"
        Action = "iam:PassRole"
        "Resource" : [
          "arn:aws:iam::090243701151:role/ecsexecution-role",
          "arn:aws:iam::090243701151:role/ecstask-role"
        ]
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "ecs-tasks.amazonaws.com"
          }
        }
      },
    ]
  })
}