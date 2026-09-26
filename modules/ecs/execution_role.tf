resource "aws_iam_role" "ecsexecution_role" {
  name = "ecsexecution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EcsExecutionRole"
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Condition = {
          "ArnLike" : {
            "aws:SourceArn" : "arn:aws:ecs:${var.region}:${var.account_id}:*"
          },
          "StringEquals" : {
            "aws:SourceAccount" : "${var.account_id}"

          }



        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "secret_manager" {
  name = "get-sceret-value"
  role = aws_iam_role.ecsexecution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
        ]
        Effect   = "Allow"
        Resource = var.db_secret_arn
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "ecs_execution_role_policy" {
  name       = "ecs-execution-role"
  roles      = [aws_iam_role.ecsexecution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}