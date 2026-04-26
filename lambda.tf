module "lambda" {
  source       = "./modules/lambda"
  environment  = var.environment
  project_name = "${var.project_name}"
  vpc_id       = module.vpc.vpc_id
}