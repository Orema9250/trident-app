resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "ecs-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512

  execution_role_arn = aws_iam_role.ecsexecution_role.arn
  task_role_arn      = aws_iam_role.ecstask_role.arn


  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = "${var.ecr_repository_url}:${var.image_tag}"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "NODE_ENV"
          value = "production"
        },
        {
          name  = "DB_HOST"
          value = var.db_address
        },
        {
          name  = "DB_PORT"
          value = tostring(var.db_port)
        },
        {
          name  = "DB_NAME"
          value = var.db_name
        }
      ]
      secrets = [
        {
          name      = "DB_USER"
          valueFrom = "${var.db_secret_arn}:username::"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "${var.db_secret_arn}:password::"
        }
      ]


      logConfiguration = {
        logDriver = "awslogs"

        options = {
          "awslogs-group"         = var.backend_logs_name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
    ]
  )


  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}
