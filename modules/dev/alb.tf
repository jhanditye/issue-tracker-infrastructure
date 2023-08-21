# Application Load Balancer 

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.7.0"
  
  name = var.alb_name
  vpc_id = module.vpc.vpc_id
  subnets = var.vpc_public_subnets
  security_groups = [module.alb_http_sg.security_group_id]

  http_tcp_listeners = [
    {
        port = 80
        protocol = "HTTP"
        target_group_index = 0 
    }
  ]

  target_groups = [
    {
        name = var.alb_target_group_name
        backend_protocol = "HTTP"
        backend_port = 80 
        target_type = "instance"
    }
  ]

  tags = var.alb_tags
}


# Load Balancer Security Group 

module "alb_http_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name = var.alb_sg_name
  vpc_id = module.vpc.vpc_id
  description = var.alb_sg_description


  ingress_cidr_blocks = var.alb_sg_ingress_cidr_blocks
  tags = var.alb_sg_tags


}
