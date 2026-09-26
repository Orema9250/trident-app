resource "aws_iam_role" "ecr_role" {
  name = "ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "GetEcrPullRole"
        Principal = {
          Service = "ecr.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "ecr_role_policy" {
  name = "ecr-role-policy"
  role = aws_iam_role.ecr_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:ecr:${var.region}:${var.account_id}:repository/ecr"
      },
    ]
  })
}
