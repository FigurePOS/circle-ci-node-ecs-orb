
terraform {
  backend "s3" {
    region = "us-east-1"
    key = "circle-ci-terraform-orb/terraform.tfstate"
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    datadog = {
      source = "datadog/datadog"
    }
  }
}

provider "aws" {
  region = var.region
  profile = var.aws_profile
}

variable "aws_profile" {}

variable "region" {
  default = "us-east-1"
}
