terraform {
  backend "s3" {
    bucket = "newbank-dev-s3-app-data"
    key    = "remote/terraform.tfstate"
    region = "eu-west-1"
    # dynamodb_table = "basic-dynamodb-table"
  }
}