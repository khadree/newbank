output "target_group_arn" {
  description = "The ARN of the Target Group to be used in ECS Service"
  value       = aws_lb_target_group.this.arn
}

output "alb_sg_id" {
  description = "The ID of the ALB Security Group"
  value       = aws_security_group.lb_sg.id
}

output "dns_name" {
  description = "The DNS name of the Load Balancer"
  value       = aws_lb.this.dns_name
}