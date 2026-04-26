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

# variable "eks_node_security_group_id" {
#   description = "Security group ID of EKS nodes (to allow DB access)"
#   type        = string
# }

variable "db_name" {
  description = "Name of the initial database"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Master username for the database"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "PostgreSQL port"
  type        = number
}

variable "instance_class" {
  description = "RDS instance type"
  type        = string
}

variable "allocated_storage" {
  description = "Initial storage in GB"
  type        = number
  
}

variable "max_allocated_storage" {
  description = "Max storage for autoscaling in GB"
  type        = number
}

variable "postgres_version" {
  description = "PostgreSQL engine version"
  type        = string
}

variable "multi_az" {
  description = "Enable Multi-AZ for high availability"
  type        = bool
}

variable "backup_retention_days" {
  description = "Number of days to retain automated backups"
  type        = number
  default     = 7  # Adding a default makes it "optional"
}

variable "deletion_protection" {
  description = "Prevent accidental deletion of the DB"
  type        = bool
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on destroy (set true for dev only)"
  type        = bool
}


variable "admin_ip" {
  type        = string
  description = "Public IP for DB maintenance"
  default     = "" # Empty by default so it's optional
}
