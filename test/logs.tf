resource "aws_cloudwatch_log_group" "log_group" {
  name = "/test/circle-ci-terraform-orb"
  retention_in_days = 365
}
