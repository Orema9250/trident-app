resource "aws_ecs_service" "backend" {
  name            = "backend"
  cluster         = aws_ecs_cluster.cloudtask_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = var.ecs_target_group_arn
    container_name   = "backend"
    container_port   = 3000
  }
  network_configuration {
    assign_public_ip = false
    subnets          = var.app_subnet_ids
    security_groups  = [aws_security_group.ecs_sg.id]
  }

  deployment_configuration {
    strategy = "ROLLING"
  }
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }


  wait_for_steady_state = true
}
