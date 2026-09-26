resource "aws_iam_role_policy" "db_policy" {
  name = "lambda-db-access"
  role = var.lambda_role_id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"
        Sid    = "DynamoDbAccess"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:Scan"
        ]

        Resource = aws_dynamodb_table.activities.arn
      }
    ]
  })
}