# --------------------------------------------------
# EC2 Instance Type
# --------------------------------------------------

variable "aws_instance_type" {

  # Description shown by Terraform when it asks
  # the user to provide a value.
  description = "What type of instance you want to create?"

  # The variable must contain a string value.
  type = string

  # Validate the value before Terraform continues.
  #
  # Only t2.micro or t3.micro are allowed.
  # If any other value is provided, Terraform
  # will stop with the specified error message.
  validation {
    condition = (
      var.aws_instance_type == "t2.micro" ||
      var.aws_instance_type == "t3.micro"
    )

    error_message = "Only t2.micro and t3.micro are allowed."
  }
}


# --------------------------------------------------
# EC2 Storage Configuration
# --------------------------------------------------

variable "ec2_config" {

  # The variable must be an object containing
  # both v_size and v_type attributes.
  type = object({
    v_size = number
    v_type = string
  })

  # Default values are used when no other value
  # is provided for this variable.
  default = {
    v_size = 30
    v_type = "gp2"
  }
}


# --------------------------------------------------
# Additional EC2 Tags
# --------------------------------------------------

variable "additional_tags" {

  # map(string) means:
  #
  # Key   -> string
  # Value -> string
  #
  # Example:
  # env  = "prod"
  # team = "backend"
  type = map(string)

  # Default tags that will be added to the EC2 instance.
  default = {
    env = "prod"
  }
}