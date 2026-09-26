resource "aws_apigatewayv2_integration" "cloudtask_integration" {
  api_id           = aws_apigatewayv2_api.cloudtask_api.id
  integration_type = "AWS_PROXY"

  connection_type        = "INTERNET"
  description            = "Lambda example"
  integration_method     = "POST"
  integration_uri        = var.lambda_function_invoke_arn
  payload_format_version = "2.0"
}