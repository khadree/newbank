variable "lifecycle_days" {
  description = "Days before objects expire"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags for the bucket"
  type        = map(string)
  default     = {}
}

variable "project_name" {
    description = "Project name"
    type        = string
}
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}
variable "bucket_name" {
  description = "Name of the S3 bucket (must be globally unique)"
  type        = string
}

variable "versioning_enabled" {
  description = "Whether versioning is enabled for the S3 bucket"
  type        = string
  default = "Enabled"
}