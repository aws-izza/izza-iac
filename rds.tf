# RDS Security Group
resource "aws_security_group" "rds" {
  name_prefix = "${var.project_name}-${var.environment}-rds-"
  description = "Security group for RDS PostgreSQL database"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-sg"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# 전체 VPC 접근 허용
# TODO: 변경해야 함
resource "aws_security_group_rule" "rds_ingress_dev_all" {
  type              = "ingress"
  description       = "PostgreSQL from entire VPC (Dev only)"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = [module.vpc.vpc_cidr_block]
  security_group_id = aws_security_group.rds.id
}

# DB Subnet Group (기존 것을 import해서 사용)
resource "aws_db_subnet_group" "izza_db_subnet" {
  name       = "izza-db-subnet"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name        = "izza-db-subnet"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier = "izza-db"

  # Engine configuration
  engine               = "postgres"
  engine_version       = "15.12"
  family               = "postgres15"
  major_engine_version = "15"
  instance_class       = "db.t4g.micro"

  # 기본 파라미터 그룹 사용 (커스텀 생성 안함)
  create_db_parameter_group = false
  parameter_group_name      = "default.postgres15"

  # Storage configuration
  allocated_storage     = 40
  max_allocated_storage = 1000
  storage_type          = "gp2"
  storage_encrypted     = true

  # Database configuration
  db_name                     = null
  username                    = "postgres"
  manage_master_user_password = true


  # Network configuration
  create_db_subnet_group = false
  db_subnet_group_name   = "izza-db-subnet"
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  availability_zone      = "ap-northeast-2a"
  multi_az               = false
  port                   = 5432

  # Backup configuration
  backup_retention_period = 1

  # Monitoring and logging
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  enabled_cloudwatch_logs_exports       = ["iam-db-auth-error", "postgresql"]

  # Other settings
  auto_minor_version_upgrade = true
  copy_tags_to_snapshot      = true
  deletion_protection        = true

  tags = {
    Name        = "izza-db"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}
