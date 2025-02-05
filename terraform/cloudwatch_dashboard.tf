resource "aws_cloudwatch_dashboard" "jeancloud_dashboard" {
  dashboard_name = "JeanCloud-Dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          title  = "ECS Backend CPU Usage"
          view   = "timeSeries"
          stacked = false
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.france.name, "ServiceName", aws_ecs_service.backend.name]
          ]
          region = "eu-west-3"
        }
      },
      {
        type = "metric"
        properties = {
          title  = "ECS Backend Memory Usage"
          view   = "timeSeries"
          stacked = false
          metrics = [
            ["AWS/ECS", "MemoryUtilization", "ClusterName", aws_ecs_cluster.france.name, "ServiceName", aws_ecs_service.backend.name]
          ]
          region = "eu-west-3"
        }
      },
      {
        type = "metric"
        properties = {
          title  = "RDS Active Connections"
          view   = "timeSeries"
          stacked = false
          metrics = [
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", aws_db_instance.france.identifier]
          ]
          region = "eu-west-3"
        }
      },
      {
        type = "metric"
        properties = {
          title  = "ALB Target Response Time"
          view   = "timeSeries"
          stacked = false
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", aws_lb.france.arn_suffix]
          ]
          region = "eu-west-3"
        }
      }
    ]
  })
}
