resource "aws_cognito_user_pool" "users" {
  name = "cloudtask-users"
}

resource "aws_cognito_user_pool_client" "frontend" {
  name         = "cloudtask-client"
  user_pool_id = aws_cognito_user_pool.users.id
}

resource "aws_apigatewayv2_authorizer" "jwt" {
  api_id           = aws_apigatewayv2_api.cloudtask_api.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "cloudtask-authorizer"
  jwt_configuration {
    audience = ["aws_cognito_user_pool_client.frontend"]
    issuer   = "https://${aws_cognito_user_pool.users.endpoint}"
  }
}

