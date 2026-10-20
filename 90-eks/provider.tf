terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.59.0"  # Version changes on everytime check current update it
    }
  }

  backend "s3" {
    bucket       = "remote-state-daws-devops"
    key          = "roboshop-dev-eks"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = "us-east-1"
}