terraform {

  # required_providers tells Terraform which providers
  # this project needs.
  required_providers {

    aws = {

      # source tells Terraform where to download
      # the AWS provider from.
      source = "hashicorp/aws"

      # version specifies which AWS provider version
      # Terraform should use.
      # "~> 6.0" means version 6.x, but not 7.x.
      version = "~> 6.0"
    }
  }
}