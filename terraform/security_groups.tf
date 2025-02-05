resource "aws_security_group" "ecs" {
  provider = aws.france
  vpc_id = aws_vpc.france.id

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    security_groups = [aws_security_group.rds.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ecs-security-group"
  }
}

resource "aws_security_group" "alb" {
  provider = aws.france
  vpc_id = aws_vpc.france.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-security-group"
  }
}

resource "aws_security_group_rule" "alb_to_ecs" {
  security_group_id        = aws_security_group.alb.id
  type                     = "egress"
  from_port                = var.backend_container_port
  to_port                  = var.backend_container_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs.id
}


resource "aws_security_group_rule" "ecs_from_alb" {
  security_group_id        = aws_security_group.ecs.id
  type                     = "ingress"
  from_port                = var.backend_container_port
  to_port                  = var.backend_container_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group" "alb_germany" {
  provider = aws.germany
  vpc_id = aws_vpc.germany.id
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-security-group-germany"
  }
}
