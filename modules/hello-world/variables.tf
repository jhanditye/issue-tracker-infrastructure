
variable "vpc_cidr" {
    type = string
    description = "The CIDR block for the issue-tracker-vpc"
    default  = "10.0.0.0/16"
}

variable "cidr_public_subnets"{
    type = list(string)
    description = "The CIDR blocks for the public subnets"
    default  = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "cidr_private_web_subnets"{
    type = list(string)
    description = "The CIDR blocks for the public subnets"
    default  = ["10.0.3.0/24", "10.0.4.0/24"]

}
variable "cidr_private_db_subnets"{
    type = list(string)
    description = "The CIDR blocks for the public subnets"
    default  = ["10.0.5.0/24", "10.0.6.0/24"]
}

variable "availability_zones"{
    type = list(string)
    description = "AZs to be used in our VPC"
    default  = ["eu-west-2a", "eu-west-2b"]
}