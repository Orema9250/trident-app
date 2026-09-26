
resource "aws_ecs_cluster" "cloudtask_cluster" {
  name = "cloudtask-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


