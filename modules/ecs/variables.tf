# --- Variables for Reusability ---
variable "project_name" {
    description = "Project name"
    type        = string
}
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to deploy RDS into"
  type        = string
}
variable "private_subnet_ids" {
  description = "Private subnet IDs for the DB subnet group"
  type        = list(string)
}
variable "region"{ 
    default = "eu-west-1"
}

variable "lb_sg_id" {
  description = "Security group ID for the load balancer"
  type        = string
}
variable "target_group_arn" {
  description = "Target group ARN for the load balancer"
  type        = string
}