locals {
  database_url_france = "postgresql://${var.db_username}:${var.db_password}@${aws_db_instance.france.address}:5432/${var.db_name}"
}

resource "aws_ecs_cluster" "france" {
  provider = aws.france
  name     = "${var.project_name}-cluster-france"
}

resource "aws_ecs_task_definition" "backend" {
  provider                   = aws.france
  family                     = "jeancloud-backend"
  network_mode               = "awsvpc"
  requires_compatibilities   = ["FARGATE"]
  execution_role_arn         = aws_iam_role.ecs_task_execution_role.arn
  cpu                        = "512"
  memory                     = "1024"

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = "${aws_ecr_repository.backend.repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = var.backend_container_port
          hostPort      = var.backend_container_port
        }
      ]
      environment = [
        { name = "DATABASE_URL", value = local.database_url_france },
        { name = "LOCAL_DATABASE_URL", value = local.database_url_france },
        { name = "SELECTED_DB", value = "remote" },
        { name = "DJANGO_SECRET_KEY", value = var.django_secret_key }
      ]
    }
  ])
}

resource "aws_ecs_service" "backend" {
  provider          = aws.france
  name             = "${var.project_name}-backend"
  cluster          = aws_ecs_cluster.france.id
  task_definition  = aws_ecs_task_definition.backend.arn
  desired_count    = 2
  launch_type      = "FARGATE"

  network_configuration {
    subnets = [aws_subnet.france_private_az1.id, aws_subnet.france_private_az2.id]
    security_groups = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.france.arn
    container_name   = "backend"
    container_port   = var.backend_container_port
  }
}

resource "aws_ecs_task_definition" "migrate_task" {
  provider                 = aws.france
  family                   = "${var.project_name}-backend-migrate"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = "512"
  memory                   = "1024"

  container_definitions = jsonencode([  
    {
      name      = "migrate"
      image     = "${aws_ecr_repository.backend.repository_url}:latest"
      essential = true
      command   = ["python", "manage.py", "migrate"]

      environment = [
        { name = "DATABASE_URL", value = local.database_url_france },
        { name = "LOCAL_DATABASE_URL", value = local.database_url_france },
        { name = "SELECTED_DB", value = "remote" }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/aws/ecs/jeancloud-backend"
          awslogs-region        = "eu-west-3"
          awslogs-stream-prefix = "ecs-migrate"
        }
      }
    }
  ])
}

resource "aws_ecs_cluster" "germany" {
  provider = aws.germany
  name     = var.ecs_cluster_germany_name
}

resource "aws_ecs_service" "germany" {
  provider         = aws.germany
  name             = "${var.project_name}-backend"
  cluster          = aws_ecs_cluster.germany.id
  task_definition  = aws_ecs_task_definition.backend_germany.arn  # <-- Nouvelle task definition
  desired_count    = 0
  launch_type      = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.germany_az1.id]
    assign_public_ip = true
  }
}

resource "aws_ecs_task_definition" "backend_germany" {
  provider                   = aws.germany
  family                     = "${var.project_name}-backend"
  network_mode               = "awsvpc"
  requires_compatibilities   = ["FARGATE"]
  cpu                        = "256"
  memory                     = "512"
  execution_role_arn         = aws_iam_role.ecs_task_execution_role_germany.arn  # 🔥 Ajout du rôle
  container_definitions = jsonencode([
    {
      name  = "backend"
      image = "${aws_ecr_repository.backend_germany.repository_url}:latest"
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "DB_HOST"
          value = "jeancloud-db-france.endpoint"
        }
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "migrate" {
  provider = aws.france
  family   = "${var.project_name}-migrate"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  cpu    = var.ecs_task_cpu
  memory = var.ecs_task_memory

  container_definitions = jsonencode([
    {
      name  = "migrate",
      image = "${aws_ecr_repository.backend.repository_url}:latest",
      essential = true,
      command = ["sh", "-c", "python manage.py migrate"],
      environment = [
        { name = "DATABASE_URL", value = "postgresql://${var.db_username}:${var.db_password}@${aws_db_instance.france.address}:5432/${var.db_name}" },
        { name = "DJANGO_SECRET_KEY", value = var.django_secret_key }
      ]
    }
  ])
}
