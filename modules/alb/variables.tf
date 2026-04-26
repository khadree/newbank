variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the ALB and Target Group will be created"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}

variable "target_port" {
  description = "The port the application is listening on (e.g., 80 or 8080)"
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "The endpoint for the ALB health check"
  type        = string
  default     = "/"
}

variable "certificate_arn" {
  description = "The ARN of the SSL certificate. Leave empty to disable HTTPS/Redirect."
  type        = string
  default     = ""  # This is crucial for the ternary logic to work
}
