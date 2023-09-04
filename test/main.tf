
terraform {
  backend "s3" {
    region = "us-east-1"
    key    = "circle-ci-terraform-orb/terraform.tfstate"
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    datadog = {
      source = "datadog/datadog"
    }

    postgresql = {
      source = "cyrilgdn/postgresql"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

provider "postgresql" {
  alias           = "main"
  host            = "localhost"
  port            = 5432
  database        = "postgres"
  username        = "twbrds"
  password        = data.aws_ssm_parameter.postgres_main_root_password.value
  superuser       = false
  sslmode         = "require"
  connect_timeout = 15
}

data "aws_ssm_parameter" "postgres_main_root_password" {
  name = "secret.service.orders.postgres_main_root_password"
}

variable "aws_profile" {}

variable "region" {
  default = "us-east-1"
}
