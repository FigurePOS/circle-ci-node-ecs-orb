resource "aws_cloudwatch_log_group" "log_group" {
  name = "/test/circle-ci-node-ecs-orb"
  retention_in_days = 400
}

resource "datadog_metric_metadata" "request_time" {
  metric      = "request.time"
  short_name  = "Request time"
  description = "99th percentile request time in millseconds"
  type        = "gauge"
  unit        = "millisecond"
}
