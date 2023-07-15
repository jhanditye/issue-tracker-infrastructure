
resource "aws_vpc" "issue-tracker-vpc"{
    cidr_block = var.vpc_cidr
    tags = {
        Name = "VPC: issue-tracker-eu-west-2"
    }
}

resource "aws_subnet" "aws_issue_tracker_public_subnets"{
    count = length(var.cidr_public_subnets)
    vpc_id = aws_vpc.issue-tracker-vpc.id
    cidr_block = element(var.cidr_public_subnets,count.index)
    availability_zone = element(var.availability_zones,count.index)

    tags = {
        Name = "Subnet-Public: Public subnet ${count.index+1}"
    }
}

resource "aws_subnet" "aws_issue_tracker_private_web_subnets"{
    count = length(var.cidr_private_web_subnets)
    vpc_id = aws_vpc.issue-tracker-vpc.id
    cidr_block = element(var.cidr_private_web_subnets,count.index)
    availability_zone = element(var.availability_zones,count.index)

    tags = {
        Name = "Subnet-Private : Private web subnet ${count.index+1}"
    }
}

resource "aws_subnet" "aws_issue_tracker_private_db_subnets"{
    count = length(var.cidr_private_db_subnets)
    vpc_id = aws_vpc.issue-tracker-vpc.id
    cidr_block = element(var.cidr_private_db_subnets,count.index)
    availability_zone = element(var.availability_zones,count.index)

    tags = {
        Name = "Subnet-Private : Private Database subnet ${count.index+1}"
    }
}