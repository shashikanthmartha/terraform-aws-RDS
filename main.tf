resource "aws_kms_key" "db_kms_key" {
  description             = "KMS key for RDS"
  deletion_window_in_days = 10
}

# Create an alias for the KMS key
resource "aws_kms_alias" "db_kms_key_alias" {
  name          = "alias/shashi_rds/rds"
  target_key_id = aws_kms_key.db_kms_key.id
}


resource "aws_db_subnet_group" "rds_subnet_group" {
  count = length(var.rds_privatesubnets) > 1 ? 1 : 0
  name       = "${var.env}-rds-subnet-group - ${count.index}"
  subnet_ids = var.rds_privatesubnets

  tags = {
    Name = "${var.env}-rds-subnet-group"
  }
}

resource "random_password" "root_password" {
  length      = 16
  special     = false
  min_numeric = 5
}

resource "aws_db_instance" "db" {
  depends_on              = [aws_db_subnet_group.rds_subnet_group]
  identifier              = "${var.env}-rds"
  allocated_storage       = var.rds_allocated_storage
  storage_type            = var.rds_storage_type
  engine                  = var.rds_engine
  engine_version          = var.rds_engine_version
  instance_class          = var.rds_instance_class
  multi_az                = var.rds_multi_az
  username                = var.rds_username
  password                = aws_ssm_parameter.db_password.value
  storage_encrypted       = var.rds_storage_encrypted
  kms_key_id              = aws_kms_key.db_kms_key.arn
  vpc_security_group_ids  = ["${aws_security_group.rds_sg.id}"]
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group[0].name
  publicly_accessible     = var.rds_publicly_accessible
  backup_retention_period = var.rds_backup_retention_period
  skip_final_snapshot     = true
}

resource "aws_ssm_parameter" "db_password" {
  name   = "/rds/${var.env}-rds/password"
  value  = var.rds_multi_az == true ? random_password.root_password.result : "test"
  type   = "SecureString"
  key_id =  aws_kms_key.db_kms_key.arn
}
resource "aws_security_group" "rds_sg" {
  name        = "${var.env}-rds-sg"
  description = "Security group for rds instances in the ASG"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.rds_sg_ingress_rules
    content {
      description     = format("Allow access for %s", ingress.key)
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = lookup(ingress.value, "protocol", "tcp")
      cidr_blocks     = lookup(ingress.value, "cidr_blocks", [])
      security_groups = lookup(ingress.value, "security_groups", [])
    }
  }
  dynamic "egress" {
    for_each = var.rds_sg_egress_rules
    content {
      description     = format("Allow access for %s", egress.key)
      from_port       = egress.value.from_port
      to_port         = egress.value.to_port
      protocol        = lookup(egress.value, "protocol", "tcp")
      cidr_blocks     = lookup(egress.value, "cidr_blocks", [])
      security_groups = lookup(egress.value, "security_groups", [])
    }
  }

  tags = {
    Name = "${var.env}-EC2SecurityGroup"
  }
}
