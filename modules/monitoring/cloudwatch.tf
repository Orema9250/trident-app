resource "aws_cloudwatch_log_group" "backend" {
  name              = "/ecs/backend"
  retention_in_days = 7

  tags = {
    Name = "backend-logs"
  }
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name                = "HighCpuAlarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 120
  statistic                 = "Average"
  threshold                 = 80
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.user_updates.arn]
  ok_actions                = [aws_sns_topic.user_updates.arn]
}

resource "aws_cloudwatch_metric_alarm" "alb_unhealthyhosts" {
  alarm_name          = "UnHealthyHostCount"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Maximum"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  alarm_description   = "Number of unhealthy nodes in Target Group"
  actions_enabled     = "true"
  alarm_actions       = [aws_sns_topic.user_updates.arn]
  ok_actions          = [aws_sns_topic.user_updates.arn]
  dimensions = {
    TargetGroup  = var.target_group_arn_suffix
    LoadBalancer = var.lb_arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "memory" {
  alarm_name          = "HighCpuMemoryAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "MemoryUtilization"
  treat_missing_data  = "notBreaching"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Number of healthy nodes in Target Group"
  actions_enabled     = "true"
  alarm_actions       = [aws_sns_topic.user_updates.arn]
  ok_actions          = [aws_sns_topic.user_updates.arn]
  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }
}


resource "aws_cloudwatch_metric_alarm" "load_balancer" {
  alarm_name          = "LoadBalancer"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2

  treat_missing_data = "notBreaching"
  threshold          = 5
  alarm_description  = "calculating Load baalancer error rate"
  actions_enabled    = "true"
  alarm_actions      = [aws_sns_topic.user_updates.arn]
  ok_actions         = [aws_sns_topic.user_updates.arn]

  metric_query {
    id          = "e1"
    expression  = "(m1+m2)/m3*100"
    label       = "5xx Error Rate in %"
    return_data = "true"
  }
  metric_query {
    id = "m1"

    metric {
      metric_name = "HTTPCode_ELB_5XX_Count"
      namespace   = "AWS/ApplicationELB"
      period      = 300
      stat        = "Sum"

      dimensions = {
        LoadBalancer = var.lb_arn_suffix
      }
    }
  }
  metric_query {
    id = "m2"

    metric {
      metric_name = "HTTPCode_TargetGroup_5XX_Count"
      namespace   = "AWS/ApplicationELB"
      period      = 300
      stat        = "Sum"

      dimensions = {
        LoadBalancer = var.lb_arn_suffix
      }
    }
  }
  metric_query {
    id = "m3"

    metric {
      metric_name = "RequestCount"
      namespace   = "AWS/ApplicationELB"
      period      = 300
      stat        = "Sum"

      dimensions = {
        LoadBalancer = var.lb_arn_suffix
      }
    }
  }
}
resource "aws_cloudwatch_metric_alarm" "lambda" {
  alarm_name          = "lambda-${var.lambda_function_name}-error"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "LambdaErrorCount"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  alarm_description   = "Triggers alarm if one or more lamdafunction error "
  actions_enabled     = "true"
  alarm_actions       = [aws_sns_topic.user_updates.arn]
  ok_actions          = [aws_sns_topic.user_updates.arn]
  dimensions = {
    FunctionName = var.lambda_function_name
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  alarm_name          = "lambda-${var.lambda_function_name}-error"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "LambdaDuration"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Maximum"
  threshold           = 3600
  treat_missing_data  = "notBreaching"
  alarm_description   = "Triggers alarm when lambda exceeds the threshold"
  actions_enabled     = "true"
  alarm_actions       = [aws_sns_topic.user_updates.arn]
  ok_actions          = [aws_sns_topic.user_updates.arn]
  dimensions = {
    FunctionName = var.lambda_function_name
  }
}

resource "aws_cloudwatch_metric_alarm" "api_gateway_5xx_count" {
  alarm_name          = "lambda-${var.api_gateway_name}-count"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ApiGatewayErrorCount"
  namespace           = "AWS/Apigateway"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  alarm_description   = "Triggers alarm if one or more lamdafunction error "
  actions_enabled     = "true"
  alarm_actions       = [aws_sns_topic.user_updates.arn]
  ok_actions          = [aws_sns_topic.user_updates.arn]
  dimensions = {
    ApiName   = var.api_gateway_name
    StageName = var.stage_name
  }
}

