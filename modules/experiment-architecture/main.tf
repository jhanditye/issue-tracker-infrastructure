resource "aws_vpc" "issue_tracker_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "VPC: issue-tracker-eu-west-2"
  }
}

resource "aws_subnet" "aws_issue_tracker_public_subnets" {
  count             = length(var.cidr_public_subnets)
  vpc_id            = aws_vpc.issue_tracker_vpc.id
  cidr_block        = element(var.cidr_public_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "Subnet-Public: Public subnet ${count.index+1}"
  }
}

resource "aws_subnet" "aws_issue_tracker_private_web_subnets" {
  count             = length(var.cidr_private_web_subnets)
  vpc_id            = aws_vpc.issue_tracker_vpc.id
  cidr_block        = element(var.cidr_private_web_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "Subnet-Private: Private web subnet ${count.index+1}"
  }
}

resource "aws_subnet" "aws_issue_tracker_private_db_subnets" {
  count             = length(var.cidr_private_db_subnets)
  vpc_id            = aws_vpc.issue_tracker_vpc.id
  cidr_block        = element(var.cidr_private_db_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "Subnet-Private: Private Database subnet ${count.index+1}"
  }
}

resource "aws_internet_gateway" "issue_tracker_internet_gateway" {
  vpc_id = aws_vpc.issue_tracker_vpc.id

  tags = {
    Name = "Issue Tracker Gateway"
  }
}

resource "aws_route_table" "issue_tracker_public_route_table" {
  vpc_id = aws_vpc.issue_tracker_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    gateway_id     = aws_internet_gateway.issue_tracker_internet_gateway.id
  }

  tags = {
    Name = "Route Table, Public, Issue Tracker"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.cidr_public_subnets)
  subnet_id      = element(aws_subnet.aws_issue_tracker_public_subnets.*.id, count.index)
  route_table_id = aws_route_table.issue_tracker_public_route_table.id
}

resource "aws_security_group" "issue_tracker_alb_sg" {
  name   = "issue-tracker-alb-sg"
  vpc_id = aws_vpc.issue_tracker_vpc.id

  tags = {
    Name = "Issue Tracker ALB Security Group"
  }
}


resource "aws_security_group_rule" "issue_tracker_alb_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.issue_tracker_alb_sg.id

  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  description = "Allow inbound HTTP from anywhere"

}

resource "aws_security_group_rule" "issue_tracker_alb_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.issue_tracker_alb_sg.id

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  description = "Allow all outbound traffic"
}

resource "aws_lb" "issue_tracker_lb" {
  name               = "issue-tracker-lb"
  load_balancer_type = "application"
  subnets            = aws_subnet.aws_issue_tracker_public_subnets[*].id
  security_groups    = [aws_security_group.issue_tracker_alb_sg.id]

  tags = {
    Name = "Issue Tracker Load Balancer"
  }
}

resource "aws_lb_listener" "issue_tracker_listener" {
  load_balancer_arn = aws_lb.issue_tracker_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.issue_tracker_target_group.arn
  }

  tags = {
    Name = "Issue Tracker Listener"
  }
}

resource "aws_lb_target_group" "issue_tracker_target_group" {
  name        = "issue-tracker-target-group"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.issue_tracker_vpc.id
  target_type = "instance"

  health_check {
    path = "/"
  }

  tags = {
    Name = "Issue Tracker Target Group"
  }
}

locals {
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World 1" > index.html
              python3 -m http.server 8080 &
              EOF
}

/* start



# Local variables
locals {
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

  name        = "demo"
  description = "desc"
  vpc_id      = aws_vpc.issue_tracker_vpc.id

  ingress_cidr_blocks = [var.vpc_cidr]

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-8080-tcp"
      source_security_group_id = aws_security_group.issue_tracker_alb_sg.id  
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_rules = ["all-all"]
}




################################################################################
# Autoscaling scaling group (ASG)
################################################################################
module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.10.0"

  # Autoscaling group
  name = "Asg"

  min_size                  = 2
  max_size                  = 3
  desired_capacity          = 2

  health_check_type         = "EC2"
  vpc_zone_identifier       = aws_subnet.aws_issue_tracker_private_web_subnets[*].id
  target_group_arns         = [aws_lb_target_group.issue_tracker_target_group.arn]
  user_data                 = base64decode(local.user_data)


  image_id          = data.aws_ami.ubuntu.id
  instance_type     = "t2.micro"


}


resource "aws_autoscaling_attachment" "terramino" {
  autoscaling_group_name = module.asg.autoscaling_group_id
  lb_target_group_arn   = aws_lb_target_group.issue_tracker_target_group.arn
}





/// end 



resource "aws_lb_target_group_attachment" "issue_tracker_target_group_attachment" {
  count            = var.instance_count
  target_group_arn = aws_lb_target_group.issue_tracker_target_group.arn
  target_id        = aws_instance.instances[count.index].id
  port             = 8080

}



resource "aws_security_group" "issue_tracker_instance_sg" {
  name        = "issue-tracker-instance-sg"
  vpc_id      = aws_vpc.issue_tracker_vpc.id

  tags = {
    Name = "Issue Tracker Instance Security Group"
  }
}

resource "aws_security_group_rule" "allow_lb_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.issue_tracker_instance_sg.id
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = aws_subnet.aws_issue_tracker_public_subnets[*].cidr_block

}

resource "aws_instance" "instances" {
  count         = var.instance_count
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = element(aws_subnet.aws_issue_tracker_private_web_subnets.*.id, count.index % 2)
  vpc_security_group_ids = [aws_security_group.issue_tracker_instance_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, World ${count.index}" > index.html
    python3 -m http.server 8080 &
  EOF

  tags = {
    Name = "EC2 Instance ${count.index+1}"
  }
}


*/

resource "aws_security_group" "terramino_instance" {
  name = "learn-asg-terramino-instance"
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.issue_tracker_alb_sg.id]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.issue_tracker_vpc.id
}

resource "aws_launch_configuration" "terramino" {
  name_prefix     = "learn-terraform-aws-asg-"
  image_id        = var.ami_id
  instance_type   = "t2.micro"
  #user_data       = base64encode(local.user_data)
  security_groups = [aws_security_group.terramino_instance.id]

}

resource "aws_autoscaling_group" "terramino" {
  min_size             = 1
  max_size             = 3
  desired_capacity     = 1
  launch_configuration = aws_launch_configuration.terramino.name
  vpc_zone_identifier  = aws_subnet.aws_issue_tracker_private_web_subnets[*].id
}


resource "aws_autoscaling_attachment" "terramino" {
  autoscaling_group_name = aws_autoscaling_group.terramino.id
  lb_target_group_arn   = aws_lb_target_group.issue_tracker_target_group.arn
}



resource "aws_route53_zone" "issue_tracker" {
  name = "www.trackitall.org"


}

resource "aws_route53_record" "issue_tracker_A_record" {
  name    = "www.trackitall.org"
  type    = "A"
  zone_id = aws_route53_zone.issue_tracker.zone_id

  alias {
    name                   = aws_lb.issue_tracker_lb.dns_name
    zone_id                = aws_lb.issue_tracker_lb.zone_id
    evaluate_target_health = true
  }
}
