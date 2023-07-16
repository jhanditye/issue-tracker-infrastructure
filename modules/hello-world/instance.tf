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

resource "aws_lb" "issue_tracker_lb" {
  name               = "issue-tracker-lb"
  load_balancer_type = "application"
  subnets            = aws_subnet.aws_issue_tracker_public_subnets[*].id

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

resource "aws_lb_target_group_attachment" "issue_tracker_target_group_attachment" {
  count            = var.instance_count
  target_group_arn = aws_lb_target_group.issue_tracker_target_group.arn
  target_id        = aws_instance.instances[count.index].id


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
    echo "Hello, World ${count.index % 2 + 1}" > index.html
    python3 -m http.server 8080 &
  EOF

  tags = {
    Name = "EC2 Instance ${count.index+1}"
  }
}