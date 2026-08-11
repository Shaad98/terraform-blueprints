# Creates an input variable named "region".
# Instead of hardcoding the AWS region in provider.tf,
# we can provide the region through this variable.
variable "region" {

  # description explains the purpose of this variable.
  description = "AWS region where resources will be provisioned"

  # default value is used if we don't provide
  # another value for the region.
  default = "us-east-1"

  # type specifies what kind of value this variable accepts.
  # string means text.
  type = string
}