resource "aws_iam_role" "terraform_githubrole" {

  name = "terraform-githubrole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_action.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          "StringEquals" : {
            "token.actions.githubusercontent.com:sub" = "repo:Orema9250@242164193/trident-app@1389503752:ref:refs/heads/main",
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
    }
  )
}