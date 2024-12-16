terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "grenale-state-bucket"
    key            = "grenale/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "grenale-terraform-lock-table"
  }
}

provider "aws" {
  region = "eu-west-2"
}
