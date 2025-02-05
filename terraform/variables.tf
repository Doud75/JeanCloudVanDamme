variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "jeancloud"
}

variable "aws_regions" {
  description = "Liste des régions utilisées"
  type        = map(string)
  default = {
    france  = "eu-west-3"
    germany = "eu-central-1"
    us = "us-east-1"
  }
}

variable "vpc_france_cidr" {
  description = "Plage d'adresses du VPC en France"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_france_cidr" {
  description = "Plage d'adresses du sous-réseau en France"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone_france" {
  description = "Zone de disponibilité pour le sous-réseau en France"
  type        = string
  default     = "eu-west-3a"
}

variable "db_name" {
  description = "Nom de la base de données PostgreSQL"
  type        = string
  default     = ""
}

variable "db_username" {
  description = "Nom d'utilisateur PostgreSQL"
  type        = string
  default     = ""
}

variable "db_password" {
  description = "Mot de passe PostgreSQL"
  type        = string
  sensitive   = true
  default     = ""
}

variable "db_instance_class" {
  description = "Type d'instance RDS"
  type = string
  default = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Taille de stockage allouée en Go"
  type = number
  default = 20
}

variable "availability_zone_france_2" {
  description = "Deuxième zone de disponibilité pour RDS en France"
  type = string
  default = "eu-west-3b"
}

variable "ecs_cluster_name" {
  description = "Nom du cluster ECS"
  type = string
  default = "jeancloud-cluster-france"
}

variable "ecs_task_cpu" {
  description = "CPU alloué pour la tâche ECS"
  type = string
  default = "256"
}

variable "ecs_task_memory" {
  description = "Mémoire allouée pour la tâche ECS"
  type = string
  default = "512"
}

variable "backend_container_port" {
  description = "Port exposé par le conteneur backend"
  type = number
  default = 8000
}

variable "django_secret_key" {
  description = "Clé secrète Django"
  type = string
  sensitive = true
  default = ""
}

variable "frontend_bucket_name" {
  description = "Nom du bucket S3 pour le frontend"
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Nom de domaine Route 53"
  type        = string
  default     = "jeancloud.rocks"
}

variable "alert_email" {
  description = "Email pour recevoir les alertes ALB"
  type        = string
  default     = ""
}

variable dns_tts {
  description = "TTL pour les enregistrements DNS"
  type        = number
  default     = 300
}
variable "vpc_germany_cidr" {
  description = "Plage d'adresses du VPC en Allemagne"
  type        = string
  default     = "10.1.0.0/16"
}

variable "subnet_germany_cidr" {
  description = "Plage d'adresses du sous-réseau en Allemagne"
  type        = string
  default     = "10.1.1.0/24"
}

variable "availability_zone_germany" {
  description = "Zone de disponibilité pour le sous-réseau en Allemagne"
  type        = string
  default     = "eu-central-1a"
}

variable "ecs_cluster_germany_name" {
  description = "Nom du cluster ECS en Allemagne"
  type        = string
  default     = "jeancloud-cluster-germany"
}

variable "subnet_germany_private_cidr" {
  description = "Plage d'adresses du sous-réseau privé en Allemagne"
  type        = string
  default     = "10.1.2.0/24"
}
