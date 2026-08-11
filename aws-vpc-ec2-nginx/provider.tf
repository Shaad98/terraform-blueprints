# Configures the AWS provider.
# The provider is responsible for communicating
# with AWS and creating/managing AWS resources.
provider "aws" {

  # region specifies the AWS region where
  # Terraform will create the resources.
  #
  # var.region gets the value from variable.tf.
  # Currently the default value is "us-east-1".
  region = var.region
}