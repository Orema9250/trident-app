output "api_gateway_name" {
  value = aws_apigatewayv2_api.cloudtask_api.name
}

output "stage_name" {
  value = aws_apigatewayv2_stage.api_stage.name
}

output "api_gateway_execution_arn" {
  value = aws_apigatewayv2_api.cloudtask_api.execution_arn
}