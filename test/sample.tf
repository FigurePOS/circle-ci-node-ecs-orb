resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/test/${var.service_name}"
  retention_in_days = 400
}

resource "datadog_metric_metadata" "request_time" {
  metric      = "request.time"
  short_name  = "Request time"
  description = "99th percentile request time in millseconds"
  type        = "gauge"
  unit        = "millisecond"
}

resource "postgresql_function" "orb_ci_test_function" {
  provider = postgresql.main
  name     = "orb_ci_test_function"
  arg {
    name = "i"
    type = "integer"
  }
  returns  = "integer"
  language = "plpgsql"
  body     = <<-EOF
        BEGIN
            RETURN i + 1;
        END;
    EOF
}
