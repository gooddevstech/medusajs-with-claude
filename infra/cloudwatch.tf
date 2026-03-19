# SNS Topic for Alarms (optional, for notifications)
resource "aws_sns_topic" "alerts" {
  name_prefix = "${var.project_name}-alerts-"

  tags = merge(var.tags, { Name = "${var.project_name}-alerts-topic" })
}

# ALB Target Group Health Check Alarms
resource "aws_cloudwatch_metric_alarm" "alb_backend_unhealthy_hosts" {
  alarm_name          = "${var.project_name}-backend-tg-unhealthy-hosts"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "Alert when backend target group has unhealthy hosts"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    TargetGroup  = module.alb.target_groups["backend"].arn_suffix
    LoadBalancer = module.alb.arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_storefront_unhealthy_hosts" {
  alarm_name          = "${var.project_name}-storefront-tg-unhealthy-hosts"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "Alert when storefront target group has unhealthy hosts"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    TargetGroup  = module.alb.target_groups["storefront"].arn_suffix
    LoadBalancer = module.alb.arn_suffix
  }
}

# ALB 5xx Errors Alarm
resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  alarm_name          = "${var.project_name}-alb-5xx-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Alert when ALB 5xx error count is high"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    LoadBalancer = module.alb.arn_suffix
  }
}

# ECS Backend CPU Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "ecs_backend_cpu_high" {
  alarm_name          = "${var.project_name}-backend-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alert when backend ECS CPU utilization is high"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ClusterName = module.ecs.cluster_name
    ServiceName = aws_ecs_service.backend.name
  }
}

# ECS Storefront CPU Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "ecs_storefront_cpu_high" {
  alarm_name          = "${var.project_name}-storefront-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alert when storefront ECS CPU utilization is high"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ClusterName = module.ecs.cluster_name
    ServiceName = aws_ecs_service.storefront.name
  }
}

# Aurora Serverless v2 CPU Utilization Alarm (per instance)
resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "${var.project_name}-aurora-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alert when Aurora writer CPU utilization is high"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    DBInstanceIdentifier = aws_rds_cluster_instance.postgres_writer.identifier
  }
}

# Aurora Serverless v2 Capacity Alarm (ACU usage approaching max)
resource "aws_cloudwatch_metric_alarm" "aurora_capacity_high" {
  alarm_name          = "${var.project_name}-aurora-capacity-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "ServerlessDatabaseCapacity"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = var.aurora_max_capacity * 0.8
  alarm_description   = "Alert when Aurora Serverless v2 capacity exceeds 80% of max ACUs"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.postgres.cluster_identifier
  }
}