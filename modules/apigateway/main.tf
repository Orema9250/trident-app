resource "aws_apigatewayv2_api" "cloudtask_api" {
  name          = "cloudtask-${terraform.workspace}"
  protocol_type = "HTTP"
}


