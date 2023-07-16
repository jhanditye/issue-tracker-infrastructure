
resource "aws_vpc" "issue_tracker_vpc"{
    cidr_block = var.vpc_cidr
    tags = {
        Name = "VPC: issue-tracker-eu-west-2"
    }
}

resource "aws_subnet" "aws_issue_tracker_public_subnets"{
    count = length(var.cidr_public_subnets)
    vpc_id = aws_vpc.issue_tracker_vpc.id
    cidr_block = element(var.cidr_public_subnets,count.index)
    availability_zone = element(var.availability_zones,count.index)

    tags = {
        Name = "Subnet-Public: Public subnet ${count.index+1}"
    }
}

resource "aws_subnet" "aws_issue_tracker_private_web_subnets"{
    count = length(var.cidr_private_web_subnets)
    vpc_id = aws_vpc.issue_tracker_vpc.id
    cidr_block = element(var.cidr_private_web_subnets,count.index)
    availability_zone = element(var.availability_zones,count.index)

    tags = {
        Name = "Subnet-Private : Private web subnet ${count.index+1}"
    }
}

resource "aws_subnet" "aws_issue_tracker_private_db_subnets"{
    count = length(var.cidr_private_db_subnets)
    vpc_id = aws_vpc.issue_tracker_vpc.id
    cidr_block = element(var.cidr_private_db_subnets,count.index)
    availability_zone = element(var.availability_zones,count.index)

    tags = {
        Name = "Subnet-Private : Private Database subnet ${count.index+1}"
    }
}

resource "aws_internet_gateway" "issue_tracker_internet_gateway"{
    
    vpc_id = aws_vpc.issue_tracker_vpc.id

    tags = {
        Name = "Issue Tracker Gateway"
    }
}

resource "aws_route_table" "issue_tracker_public_route_table"{
    vpc_id = aws_vpc.issue_tracker_vpc.id
    route{
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.issue_tracker_internet_gateway.id
    }
    tags = {
        Name = "Route Table, Public, Issue Tracker"
    }

}


resource "aws_instance" "instances" {
  count         = 4
  ami           = "ami-0eb260c4d5475b901"
  instance_type = "t2.micro"

  subnet_id        = element(aws_subnet.aws_issue_tracker_private_web_subnets.*.id, count.index % 2)
  vpc_security_group_ids  = [aws_security_group.instances.id]

  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, World ${count.index % 2 + 1}" > index.html
    python3 -m http.server 8080 &
  EOF

  tags = {
    Name = "EC2 Instance ${count.index+1}"
  }
}
resource "aws_security_group" "instances"{
    name = "issue_tracker_instances"
    vpc_id = aws_vpc.issue_tracker_vpc.id
    depends_on = [ aws_vpc.issue_tracker_vpc]
    tags = {
        Name = "Issue Tracker EC2 Instances Security Group"
    }
}


resource "aws_security_group_rule" "allow_http_inbound"{
    type = "ingress"
    security_group_id = aws_security_group.instances.id

    from_port = 8080
    to_port = 8080

    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}


