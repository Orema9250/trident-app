output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}


output "ecs_target_group_arn" {
  value = aws_lb_target_group.ecs_backend_tg.arn
}

output "target_group_arn_suffix" {
  value = aws_lb_target_group.ecs_backend_tg.arn_suffix
}

output "lb_arn_arn_suffix" {
  value = aws_lb.lb.arn_suffix
}

output "alb_dns_name" {
  value = aws_lb.lb.dns_name
}

output "alb_zone_id" {
  value = aws_lb.lb.zone_id
}