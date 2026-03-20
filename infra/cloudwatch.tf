# SNS Topic for Alarms
resource "aws_sns_topic" "alerts" {
  name_prefix = "${var.project_name}-alerts-"

  tags = merge(var.tags, { Name = "${var.project_name}-alerts-topic" })
}

# Lambda Backend Error Rate Alarm
resource "aws_cloudwatch_metric_alarm" "lambda_backend_errors" {
  alarm_name          = "${var.project_name}-backend-lambda-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Alert when backend Lambda error count is high"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.backend.function_name
  }
}

# Lambda Storefront Error Rate Alarm
resource "aws_cloudwatch_metric_alarm" "lambda_storefront_errors" {
  alarm_name          = "${var.project_name}-storefront-lambda-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Alert when storefront Lambda error count is high"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.storefront.function_name
  }
}

# Lambda Backend Throttle Alarm
resource "aws_cloudwatch_metric_alarm" "lambda_backend_throttles" {
  alarm_name          = "${var.project_name}-backend-lambda-throttles"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "Alert when backend Lambda is being throttled"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.backend.function_name
  }
}

# Lambda Backend Duration Alarm (approaching 29s timeout)
resource "aws_cloudwatch_metric_alarm" "lambda_backend_duration" {
  alarm_name          = "${var.project_name}-backend-lambda-duration"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = 300
  extended_statistic  = "p95"
  threshold           = 20000
  alarm_description   = "Alert when backend Lambda p95 duration exceeds 20s"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.backend.function_name
  }
}

# Aurora Serverless v2 CPU Utilization Alarm
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

# Aurora Serverless v2 Capacity Alarm
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
