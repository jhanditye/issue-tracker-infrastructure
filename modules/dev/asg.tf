
# SSH Key 
resource "aws_key_pair" "ssh" {
  key_name   = "issue_tracker_ssh_key"
  public_key = local.ssh_public_key
}

# Local variables
locals {
  ssh_public_key = file("/home/jamie/my-key-pair.pub")
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World 1" > index.html
              python3 -m http.server 8080 &
              EOF
}

################################################################################
# Supporting Resources
################################################################################
module "asg_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = var.asg_sg_name
  description = var.asg_sg_description
  vpc_id      = module.vpc.vpc_id

  ingress_rules = ["ssh-tcp"]
  ingress_cidr_blocks = [var.vpc_cidr]

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-8080-tcp"
      source_security_group_id = module.alb_http_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_rules = ["all-all"]
  tags = var.asg_sg_tags
}

################################################################################
# Autoscaling scaling group (ASG)
################################################################################
module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.10.0"

  # Autoscaling group
  name = var.asg_name
  key_name = aws_key_pair.ssh.key_name

  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  desired_capacity          = var.asg_desired_capacity
  wait_for_capacity_timeout = var.asg_wait_for_capacity_timeout
  health_check_type         = var.asg_health_check_type
  vpc_zone_identifier       = module.vpc.private_subnets
  target_group_arns         = module.alb.target_group_arns
  user_data                 = base64encode(local.user_data)

  # Launch template
  launch_template_name        = var.asg_launch_template_name
  launch_template_description = var.asg_launch_template_description
  update_default_version      = var.asg_update_default_version

  image_id          = data.aws_ami.ubuntu.id
  instance_type     = var.asg_instance_type
  ebs_optimized     = var.asg_ebs_optimized
  enable_monitoring = var.asg_enable_monitoring

  tag_specifications = [
    {
      resource_type = "instance"
      tags          = var.asg_instance_tags
    },
    {
      resource_type = "volume"
      tags          = var.asg_volume_tags
    }
  ]

  tags = var.asg_tags
}


