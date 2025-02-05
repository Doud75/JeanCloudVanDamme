#Ce fichier permet d'afficher les informations de sortie de notr infra, 
#en gros c'est ce qu'on veut voir après l'avoir déployé

# Sortie des serveurs de noms
output "nameservers" {
  description = "Liste des serveurs de noms pour la zone Route 53."
  value       = aws_route53_zone.main.name_servers
}

output "frontend_domain" {
  description = "URL du frontend de l'application"
  value       = "www.${var.domain_name}"
}

output "backend_domain" {
  description = "URL de l'API backend"
  value       = "api.${var.domain_name}"
}

output "route53_zone_id" {
  description = "ID de la zone Route 53, utile pour des configurations futures"
  value       = aws_route53_zone.main.id
}

output "health_check_status" {
  description = "État des health checks configurés"
  value = {
    france_status  = aws_route53_health_check.france_alb.id
    backend_status = "Configuré avec failover France -> Allemagne"
  }
}