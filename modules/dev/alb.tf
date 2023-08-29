# Application Load Balancer 

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.7.0"
  name = var.alb_name
  vpc_id = module.vpc.vpc_id
  subnets = module.vpc.public_subnets
  create_security_group = var.create_security_group 
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
        backend_port = 8080 
        target_type = "instance"

         # Health check parameters
        health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = 8080
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
    

    }
  ]

  tags = var.alb_tags
}


# Load Balancer Security Group 

module "alb_http_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name = var.alb_sg_name
  vpc_id = module.vpc.vpc_id
  description = var.alb_sg_description
  tags = var.alb_sg_tags

  
}


resource "aws_security_group_rule" "issue_tracker_alb_http_inbound" {
  type              = "ingress"
  security_group_id = module.alb_http_sg.security_group_id

  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  description = "Allow inbound HTTP from anywhere"

}

resource "aws_security_group_rule" "issue_tracker_alb_all_outbound" {
  type              = "egress"
  security_group_id = module.alb_http_sg.security_group_id

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  description = "Allow all outbound traffic"
}



