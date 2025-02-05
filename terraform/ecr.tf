data "aws_caller_identity" "current" {}

resource "aws_ecr_repository" "backend" {
  provider = aws.france
  name = "${var.project_name}-backend"
  tags = {
    Name = "${var.project_name}-ecr-france"
  }
}

resource "aws_ecr_repository" "backend_germany" {
  provider = aws.germany
  name     = "${var.project_name}-backend"
  tags = {
    Name = "${var.project_name}-ecr-germany"
  }
}

resource "aws_ecr_replication_configuration" "replica" {
  provider = aws.france

  replication_configuration {
    rule {
      destination {
        region      = "eu-central-1"
        registry_id = data.aws_caller_identity.current.account_id
      }
    }
  }
}

