resource "aws_db_subnet_group" "france" {
  provider = aws.france
  name = "${var.project_name}-rds-subnet-group"
  subnet_ids = [aws_subnet.france_az1.id, aws_subnet.france_az2.id]

  tags = {
    Name = "${var.project_name}-rds-subnet-group"
  }
}

resource "aws_security_group" "rds" {
  provider = aws.france
  vpc_id = aws_vpc.france.id

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = [var.vpc_france_cidr]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-rds-security-group"
  }
}

# resource "aws_security_group_rule" "allow_ecs_to_rds" {
#   type                     = "ingress"
#   from_port                = 5432
#   to_port                  = 5432
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.rds.id
#   source_security_group_id = aws_security_group.ecs.id
# }


resource "aws_db_instance" "france" {
  identifier              = "${var.project_name}-db"
  engine                  = "postgres"
  engine_version          = "15"
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  storage_encrypted       = true
  publicly_accessible     = false
  vpc_security_group_ids  = [aws_security_group.rds.id]
  db_subnet_group_name    = aws_db_subnet_group.france.name
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  skip_final_snapshot     = true
  final_snapshot_identifier = "final-snapshot-name"
  backup_retention_period = 7
  backup_window           = "02:00-03:00"
  tags = {
    Name = "${var.project_name}-db-france"
  }
}

resource "aws_db_parameter_group" "postgres_params" {
  name   = "jeancloud-postgres-params"
  family = "postgres13"

  parameter {
    name  = "log_statement"
    value = "all"
  }
}

