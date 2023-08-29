resource "aws_lb_target_group_attachment" "issue_tracker_target_group_attachment" {
  count            = var.instance_count
  target_group_arn = module.alb.target_group_arns[0]
  target_id        = aws_instance.instances[count.index].id
  port             = 8080

}

resource "aws_security_group" "issue_tracker_instance_sg" {
  name        = "issue-tracker-instance-sg"
  vpc_id      = module.vpc.vpc_id

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
  cidr_blocks       = var.vpc_public_subnets

}

resource "aws_instance" "instances" {
  count         = var.instance_count
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = element(module.vpc.private_subnets, count.index % length(module.vpc.private_subnets))
  vpc_security_group_ids = [aws_security_group.issue_tracker_instance_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, World ${count.index}" > index.html
    nohup python3 -m http.server 8080 &
  EOF

  tags = {
    Name = "EC2 Instance ${count.index+1}"
  }
}
