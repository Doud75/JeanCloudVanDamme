# Ici on définit que la France est le domaine par défaut,
# on pourrait mettre les allemands mais "ICI c'est PARIS"

resource "aws_route53_zone" "main" {
  provider = aws.france 
  name     = var.domain_name 

  tags = {
    Name = "${var.project_name}-zone"
  }
}

# On crée un enregistrement DNS pour le frontend et un pour le backend
# y'a pas besoin de passer par name.com(notre fournisseur de nom de domaine) pour les creer c'est le service d'AWS qui s'en occupe 

resource "aws_route53_record" "frontend" {
  provider = aws.france
  zone_id  = aws_route53_zone.main.zone_id
  name     = "www.${var.domain_name}"
  type     = "A"

  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "backend_france" {
  provider = aws.france
  zone_id  = aws_route53_zone.main.zone_id
  name     = "api.${var.domain_name}"
  type     = "A"

#ici on dit que de base le tarif part depuis la france  et dans le backend_germany on dirait sinon tu vas là bas
failover_routing_policy {
  type= "PRIMARY"
  
}
set_identifier = "france-primary"
alias {
   name                   = aws_lb.france.dns_name
   zone_id                = aws_lb.france.zone_id
   evaluate_target_health = true
}
  health_check_id = aws_route53_health_check.france_alb.id
}

resource "aws_route53_record" "backend_germany" {
  provider = aws.germany
  
  #Attention ici faut laisser la même zone_id que le backend France
  # parce que c'est le système de failover qui décidera lequel utiliser
  zone_id  = aws_route53_zone.main.zone_id
  
  name     = "api.${var.domain_name}"
  type     = "A"

  failover_routing_policy {
    type = "SECONDARY"
  }
set_identifier = "germany-secondary"
  alias {

    name                   = aws_lb.germany.dns_name
    zone_id                = aws_lb.germany.zone_id
    evaluate_target_health = true
  }
}


# On crée un health check pour vérifier que l'ALB en France est bien en ligne
# C'est ce health check qui sera utilisé pour le failover
# plutot que de taper  sur la santé de l'ESC l'alb est plus rapide pour nous donner l'etat de santé
resource "aws_route53_health_check" "france_alb" {
  provider = aws.france
  fqdn              = aws_lb.france.dns_name
  port              = 443
  type              = "HTTPS"
  resource_path     = "/"
  request_interval  = "30"
  failure_threshold = "3"
  tags = {
    Name = "${var.project_name}-france-health"
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_health_france" {
  provider = aws.france
  alarm_name          = "${var.project_name}-alb-health-france"

  comparison_operator = "LessThanThreshold"
  
  evaluation_periods  = "2"
  
  metric_name         = "HealthyHostCount"
  
  namespace           = "AWS/ApplicationELB"
  
  period             = "60"
  
  statistic          = "Average"
  
  threshold          = 1

  dimensions = {
    TargetGroup  = aws_lb_target_group.france.arn_suffix
    LoadBalancer = aws_lb.france.arn_suffix
  }
}

resource "aws_sns_topic" "alb_alerts" {
  provider = aws.france
  name     = "${var.project_name}-alb-alerts"
}

