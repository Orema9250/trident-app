resource "aws_apigatewayv2_stage" "api_stage" {
  api_id      = aws_apigatewayv2_api.cloudtask_api.id
  name        = terraform.workspace
  auto_deploy = true
}