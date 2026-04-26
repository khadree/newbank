variable "project_name" {
  description = "Project name"
  type        = string
}
variable "region" {
  description = "AWS region"
  type        = string
}
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "s3_bucket" {
  description = "Map of S3 bucket to create (keyed by instance id/name)."
  type        = map(any)
  default = {
  }
}

variable "alb" {
  description = "Map of ALB configurations"
  type        = map(any)
  default = {
    # "primary" = {} # This creates one instance keyed as "primary"
  }
}
variable "rds" {
  description = "Map of Redis instances to create (keyed by instance id/name)."
  type        = map(any)
  default = {
    # "primary" = {} # This creates one instance keyed as "primary"
  }
}

variable "admin_ip" {
  type        = string
  description = "Public IP for DB maintenance"
  default     = "" # Empty by default so it's optional
}


variable "versioning_enabled" {
  description = "Whether versioning is enabled for the S3 bucket"
  type        = string
  default = "Enabled"
}