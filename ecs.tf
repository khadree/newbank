module "ecs" {
  source             = "./modules/ecs" # Path to the code above
  environment        = var.environment
  project_name       = "${var.project_name}"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  lb_sg_id           = module.alb["app-alb"].alb_sg_id
  target_group_arn   = module.alb["app-alb"].target_group_arn
}

