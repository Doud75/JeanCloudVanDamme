output "ecr_repository_url" {
  value = aws_ecr_repository.backend.repository_url
}

output "db_subnet_ids" {
  value = aws_db_subnet_group.france.subnet_ids
}

output "db_security_group_id" {
  value = aws_security_group.rds.id
}

output "database_url" {
  value = "postgresql://${var.db_username}:${var.db_password}@${aws_db_instance.france.address}:5432/${var.db_name}"
  sensitive = true
}

output "cloudfront_distribution_id" {
  description = "L'ID de la distribution CloudFront"
  value       = aws_cloudfront_distribution.main.id
}

output "cloudfront_domain_name" {
  description = "Le nom de domaine CloudFront"
  value       = aws_cloudfront_distribution.main.domain_name
}

