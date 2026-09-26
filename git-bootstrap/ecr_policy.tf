
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
    ]
  })
}