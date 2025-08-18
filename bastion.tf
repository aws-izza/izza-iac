# Data source for existing Key Pair
data "aws_key_pair" "izza_key" {
  key_name = "izza-key"
}

# Bastion Host Security Group
resource "aws_security_group" "bastion" {
  name_prefix = "${var.project_name}-${var.environment}-bastion-"
  description = "Security group for Bastion Host"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name        = "${var.project_name}-${var.environment}-bastion-sg"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Bastion Host Security Group Rules
resource "aws_security_group_rule" "bastion_ssh_ingress" {
  type        = "ingress"
  description = "SSH access from allowed IPs"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = var.workspace_ip_cidrs
  security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "bastion_egress_all" {
  type              = "egress"
  description       = "All outbound traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
}


# Security Group for resources that allow SSH from Bastion
resource "aws_security_group" "bastion_ssh_access" {
  name_prefix = "${var.project_name}-${var.environment}-bastion-ssh-"
  description = "Allow SSH access from Bastion Host"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name        = "${var.project_name}-${var.environment}-bastion-ssh-sg"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Allow SSH from Bastion Host
resource "aws_security_group_rule" "allow_ssh_from_bastion" {
  type                     = "ingress"
  description              = "SSH access from Bastion Host"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id        = aws_security_group.bastion_ssh_access.id
}




# Data source for AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# IAM Instance Profile (기존 것을 import)
resource "aws_iam_instance_profile" "ec2_custom_full_access" {
  name = "ec2-custom-full-access"
  role = aws_iam_role.ec2_custom_full_access.name

  tags = {
    Name        = "ec2-custom-full-access"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# IAM Role (기존 것을 import)
resource "aws_iam_role" "ec2_custom_full_access" {
  name        = "ec2-custom-full-access"
  description = "Allows EC2 instances to call AWS services on your behalf."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "ec2-custom-full-access"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# IAM Role Policy Attachments
resource "aws_iam_role_policy_attachment" "ec2_full_access" {
  role       = aws_iam_role.ec2_custom_full_access.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "ecr_full_access" {
  role       = aws_iam_role.ec2_custom_full_access.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_role_policy_attachment" "rds_full_access" {
  role       = aws_iam_role.ec2_custom_full_access.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

resource "aws_iam_role_policy_attachment" "secrets_manager_read_write" {
  role       = aws_iam_role.ec2_custom_full_access.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_role_policy_attachment" "vpc_full_access" {
  role       = aws_iam_role.ec2_custom_full_access.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

resource "aws_iam_role_policy_attachment" "s3_full_access" {
  role       = aws_iam_role.ec2_custom_full_access.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_full_access" {
  role       = aws_iam_role.ec2_custom_full_access.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
}

# Bastion Host EC2 Instance
resource "aws_instance" "bastion" {
  ami                         = "ami-008e20914908f5345" # 기존 AMI ID 사용
  instance_type               = "t3.micro"
  key_name                    = data.aws_key_pair.izza_key.key_name
  subnet_id                   = module.vpc.public_subnets[1] # subnet-08a3d7098429cfa5b (public subnet 2)
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_custom_full_access.name
  associate_public_ip_address = true

  # EBS 최적화 및 기타 설정
  ebs_optimized = true
  monitoring    = false

  # Root volume 설정
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    delete_on_termination = true
    encrypted             = false
  }

  # 메타데이터 옵션
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "disabled"
  }

  tags = {
    Name        = "bastion-host"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }

  lifecycle {
    ignore_changes = [
      ami, # AMI 변경 무시
      user_data,
      user_data_base64
    ]
  }
}