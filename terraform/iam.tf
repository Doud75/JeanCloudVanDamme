
resource "aws_iam_role" "ecs_task_execution_role" {
  provider = aws.france
  name     = "${var.project_name}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_cloudwatch_logs" {
  provider   = aws.france
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_ecr_access" {
  provider   = aws.france
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role" "ecs_task_execution_role_germany" {
  provider = aws.germany
  name     = "jeancloud-ecs-execution-role-germany"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_cloudwatch_logs_germany" {
  provider   = aws.germany
  role       = aws_iam_role.ecs_task_execution_role_germany.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_germany" {
  provider   = aws.germany
  role       = aws_iam_role.ecs_task_execution_role_germany.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "github_actions_role" {
  provider = aws.france
  name     = "github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:sub" = "repo:TonRepo/TonProjet:ref:refs/heads/main"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "github_ci_cd_policy" {
  provider = aws.france
  name     = "GitHubCI-CDPolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:ListBucket",
          "s3:GetObject",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_policy_attachment" {
  provider   = aws.france
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_ci_cd_policy.arn
}


locals {
  github_ips = jsondecode(file("${path.module}/github_ips.json"))
}

resource "aws_ec2_managed_prefix_list" "github_actions_ips" {
  name          = "github-actions-ips"
  address_family = "IPv4"
  max_entries    = length(local.github_ips)

  dynamic "entry" {
    for_each = slice(local.github_ips, 0, 40)
    content {
      cidr        = entry.value
      description = "GitHub Actions IP"
    }
  }
}

resource "aws_security_group_rule" "github_actions_access" {
  type                   = "ingress"
  from_port              = 5432
  to_port                = 5432
  protocol               = "tcp"
  security_group_id      = aws_security_group.rds.id
  prefix_list_ids        = [aws_ec2_managed_prefix_list.github_actions_ips.id]
  description            = "Allow GitHub Actions to access RDS"
}
