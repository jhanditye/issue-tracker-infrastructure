/*
# RDS Security groups

module "rds_security_group" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 4.0"
  name        = var.rds_sg_name
  description = var.rds_sg_description
  vpc_id      = module.vpc.vpc_id
  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "postgresql-tcp"
      source_security_group_id = module.asg_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1
  tags                                                     = var.rds_sg_tags
}


# RDS


module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "5.1.0"

  identifier = var.rds_identifier

  engine               = "postgres"  
  engine_version       = var.rds_engine_version
  family               = var.rds_family               
  major_engine_version = var.rds_major_engine_version 
  instance_class       = var.rds_instance_class

  allocated_storage     = var.rds_allocated_storage
  max_allocated_storage = var.rds_max_allocated_storages
  storage_encrypted = var.rds_storage_encrypted

  db_name  = var.rds_db_name
  username = var.rds_username
  port     = var.rds_port
  password = data.aws_secretsmanager_secret_version.db_secret.secret_string



  multi_az               = var.rds_multi_az
  subnet_ids             = module.vpc.database_subnets
  vpc_security_group_ids = [module.rds_security_group.security_group_id]

  maintenance_window              = var.rds_maintenance_window
  backup_window                   = var.rds_backup_window
  enabled_cloudwatch_logs_exports = var.rds_enabled_cloudwatch_logs_exports
  create_cloudwatch_log_group     = var.rds_create_cloudwatch_log_group

  backup_retention_period = var.rds_backup_retention_period
  skip_final_snapshot     = var.rds_skip_final_snapshot
  deletion_protection     = var.rds_deletion_protection

  performance_insights_enabled          = var.rds_performance_insights_enabled
  performance_insights_retention_period = var.rds_performance_insights_retention_period
  create_monitoring_role                = var.rds_create_monitoring_role
  monitoring_interval                   = var.rds_monitoring_interval
  db_subnet_group_name                  = module.vpc.database_subnet_group

  tags                    = var.rds_tags
  db_instance_tags        = var.rds_db_instance_tags
  db_option_group_tags    = var.rds_db_option_group_tags
  db_parameter_group_tags = var.rds_db_parameter_group_tags
  db_subnet_group_tags    = var.rds_db_subnet_group_tags
}


*/