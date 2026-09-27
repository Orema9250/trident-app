locals {
  routes = {
    get_activities = {
      route_key = "GET /activities"
      protected = true
    }

    create_activities = {
      route_key = "POST /activities"
      protected = true
    }
    get_activity = {
      route_key = "GET /activities/{id}"
      protected = true
    }
    update_activities = {
      route_key = "PUT /activities/{id}"
      protected = true
    }
    delete_activities = {
      route_key = "DELETE /activities/{id}"
      protected = true
    }
  }
}

resource "aws_apigatewayv2_route" "health" {
  api_id    = aws_apigatewayv2_api.cloudtask_api.id
  route_key = "GET /health"
  target    = "integrations/${aws_apigatewayv2_integration.cloudtask_integration.id}"
}


resource "aws_apigatewayv2_route" "cloudtask_route" {
  for_each           = local.routes
  api_id             = aws_apigatewayv2_api.cloudtask_api.id
  route_key          = each.value.route_key
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.jwt.id
  target             = "integrations/${aws_apigatewayv2_integration.cloudtask_integration.id}"

}