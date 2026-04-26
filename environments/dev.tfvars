# Global Variables
project_name = "newbank"
environment  = "dev"
region       = "eu-west-1"



vpc_cidr = "10.0.0.0/16"

rds = {
  "database" = {
    # RDS Configuration
    postgres_version      = "15.16"
    instance_class        = "db.t3.medium"
    allocated_storage     = 20
    max_allocated_storage = 100
    db_name               = "netacaddb"
    db_username           = "dbadmin"
    db_password           = "" # Use a secret manager in prod
    db_port               = 5432
    multi_az              = false
    backup_retention_days = 7
    deletion_protection   = false
    skip_final_snapshot   = true
  },
}

s3_bucket = {
  "app-data" = {} # Uses default module values
  # "user-assets" = {}
}

alb = {
  "app-alb" = {
    # ALB Configuration
  }
}