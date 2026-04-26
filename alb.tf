module "alb" {
  for_each     = var.alb
  source       = "./modules/alb"
  project_name = "${var.project_name}"
  environment  = "prod"

  vpc_id         = module.vpc.vpc_id
  public_subnets = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]

  target_port       = 80
  health_check_path = "/"
  # Set this to enable HTTPS and auto-redirect from port 80
  # certificate_arn = "arn:aws:acm:region:account:certificate/id"
}
