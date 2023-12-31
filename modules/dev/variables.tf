# Generic variables
variable "region" {
  description = "Region code"
  type        = string
  default     = "eu-west-2"
}

# VPC variables


variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "issue-tracker-vpc"
}

variable "vpc_cidr" {
  description = "VPC CIDR range"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_azs" {
  description = "List of AZs"
  type        = list(string)
  default     = ["eu-west-2a", "eu-west-2b"]
}

variable "vpc_public_subnets" {
  description = "List of public subnet CIDR ranges"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "vpc_private_subnets" {
  description = "List of private subnet CIDR ranges"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "vpc_database_subnets" {
  description = "List of database subnet CIDR ranges"
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
}

variable "vpc_tags" {
  description = "Tags to apply to the VPC hosting the three-tier web application."
  type        = map(string)
  default     = {
    "Name"           = "Three-Tier Web App VPC",
    "Tier"           = "Web-App-Data",
    "created-by"     = "terraform",
    "architecture"   = "three-tier"
  }
}


# Instance variables

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "instance_count" {
  description = "EC2 instance count"
  type        = number
  default     = 2
}

# ALB variables
variable "alb_sg_name" {
  description = "Application load balancer security group name"
  type        = string
  default     = "issue-tracker-alb-sg"
}

variable "alb_sg_ingress_cidr_blocks" {
  description = "Application load balancer cidr blocks"
  type        = list(any)
  default     = ["0.0.0.0/0"]
}

variable "create_security_group" {
  description = "Should LB create security group"
  type        = bool
  default     = false
}


variable "alb_sg_description" {
  description = "Application load balancer security group description"
  type        = string
  default     = "issue-tracker-alb-sg"
}

variable "alb_sg_tags" {
  description = "Application load balancer security group tags"
  type        = map(string)
  default     = { "Name" = "issue-tracker-alb-sg", "created-by" = "terraform" }
}

variable "alb_description" {
  description = "Application load balancer description"
  type        = string
  default     = "issue-tracker-alb"
}

variable "alb_name" {
  description = "Application load balancer name"
  type        = string
  default     = "issue-tracker-alb"
}

variable "alb_http_tcp_listeners_port" {
  description = "Application load balancer http listeners port"
  type        = number
  default     = 80
}

variable "alb_target_group_name" {
  description = "Application load balancer target group name"
  type        = string
  default     = "issue-tracker-alb-tg"
}

variable "alb_target_groups_backend_port" {
  description = "Application load balancer http listeners port"
  type        = number
  default     = 80
}

variable "alb_tags" {
  description = "Application load balancer tags"
  type        = map(string)
  default     = { "Name" = "issue-tracker-alb", "created-by" = "terraform" }
}

# RDS variables
variable "rds_sg_name" {
  description = "Relational database service security group name"
  type        = string
  default     = "issue-tracker-rds-sg"
}

variable "rds_sg_description" {
  description = "Relational database service security group description"
  type        = string
  default     = "issue-tracker-rds-sg"
}

variable "rds_sg_tags" {
  description = "Relational database service security group tags"
  type        = map(string)
  default     = { "Name" = "issue-tracker-rds-sg", "created-by" = "terraform" }
}

variable "rds_identifier" {
  description = "Relational database service identifier"
  type        = string
  default     = "issue-tracker-rds"
}

variable "rds_mysql_engine" {
  description = "Relational database service mysql engine"
  type        = string
  default     = "postgres"
}

variable "rds_engine_version" {
  description = "Relational database service mysql engine version"
  type        = string
  default     = "15.3"
}

variable "rds_family" {
  description = "Relational database service family"
  type        = string
  default     = "postgres15"
}

variable "rds_major_engine_version" {
  description = "Relational database service major engine version"
  type        = string
  default     = "15"
}

variable "rds_instance_class" {
  description = "Relational database service instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "Relational database service allocated storage"
  type        = number
  default     = 20
}

variable "rds_max_allocated_storage" {
  description = "Relational database service max allocated storage"
  type        = number
  default     = 100
}

variable "rds_storage_encrypted" {
  description = "Encryption at rest status"
  type        = bool
  default     = true
}


variable "rds_db_name" {
  description = "Relational database service db name"
  type        = string
  default     = "IssueTrackerPostgresDB"
}

variable "rds_username" {
  description = "Relational database service username"
  type        = string
  default     = "trackitall_dev"
}

variable "rds_port" {
  description = "Relational database service port"
  type        = number
  default     = 5432
}

data "aws_secretsmanager_secret_version" "db_secret" {
  secret_id = "arn:aws:secretsmanager:eu-west-2:909656370298:secret:dev/issue-tracker/postgresql-WIXSJU"
}

variable "rds_multi_az" {
  description = "Relational database service multi az"
  type        = bool
  default     = false
}

variable "rds_maintenance_window" {
  description = "Relational database service maintenance window"
  type        = string
  default     = "Mon:00:00-Mon:03:00"
}

variable "rds_backup_window" {
  description = "Relational database service backup window"
  type        = string
  default     = "03:00-06:00"
}

variable "rds_enabled_cloudwatch_logs_exports" {
  description = "Relational database service enabled cloudwatch log exports"
  type        = list(any)
  default     = ["postgresql", "upgrade"]
}

variable "rds_create_cloudwatch_log_group" {
  description = "Relational database service create cloudwatch log group"
  type        = bool
  default     = true
}

variable "rds_backup_retention_period" {
  description = "Relational database service backup retention period"
  type        = number
  default     = 0
}

variable "rds_skip_final_snapshot" {
  description = "Relational database service skip final snapshot"
  type        = bool
  default     = true
}

variable "rds_deletion_protection" {
  description = "Relational database service deletion protection"
  type        = bool
  default     = false
}

variable "rds_performance_insights_enabled" {
  description = "Relational database service insights enabled"
  type        = bool
  default     = false
}

variable "rds_performance_insights_retention_period" {
  description = "Relational database service retention period"
  type        = number
  default     = 7
}

variable "rds_create_monitoring_role" {
  description = "Relational database service create monitoring role"
  type        = bool
  default     = true
}

variable "rds_monitoring_interval" {
  description = "Relational database service monitoring interval"
  type        = number
  default     = 60
}

variable "rds_tags" {
  description = "Relational database service tags"
  type        = map(string)
  default     = { "Name" = "issue-tracker-rds", "created-by" = "terraform" }
}

variable "rds_db_instance_tags" {
  description = "Relational database service db instance tags"
  type        = map(string)
  default     = { "Name" = "issue-tracker-rds", "created-by" = "terraform" }
}

variable "rds_db_option_group_tags" {
  description = "Relational database service db option group tags"
  type        = map(string)
  default     = { "Name" = "issue-tracker-rds", "created-by" = "terraform" }
}

variable "rds_db_parameter_group_tags" {
  description = "Relational database service db parameter group tags"
  type        = map(string)
  default     = { "Name" = "issue-tracker-rds", "created-by" = "terraform" }
}

variable "rds_db_subnet_group_tags" {
  description = "Relational database service db subnet group tags"
  type        = map(string)
  default     = { "Name" = "issue-tracker-rds", "created-by" = "terraform" }
}