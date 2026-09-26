resource "aws_iam_role" "ecstask_role" {
  name = "ecstask-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EcsTaskRole"
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
            "aws:SourceAccount" = var.account_id

          }


        }
      }

    ]
  })

  tags = {
    tag-key = "ecs-task"
  }
}
