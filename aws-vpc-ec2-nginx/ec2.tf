# Creates an EC2 instance.
resource "aws_instance" "nginx_server" {

  # ami specifies the Amazon Machine Image (AMI)
  # that will be used to create the EC2 instance.
  #
  # This AMI contains the operating system and
  # other software required to boot the server.
  ami = "ami-0bdc7d025135d7b49"

  # instance_type specifies the hardware configuration
  # of the EC2 instance.
  #
  # t3.micro is a small instance type suitable
  # for learning/testing.
  instance_type = "t3.micro"

  # subnet_id specifies which subnet the EC2 instance
  # will be launched into.
  #
  # Here we are placing the instance inside our
  # public subnet.
  subnet_id = aws_subnet.public_subnet.id

  # vpc_security_group_ids specifies the security groups
  # attached to this EC2 instance.
  #
  # aws_security_group.nginx_sg.id means:
  # Resource type = aws_security_group
  # Resource name = nginx_sg
  # Attribute     = id
  vpc_security_group_ids = [
    aws_security_group.nginx_sg.id
  ]

  # associate_public_ip_address = true means AWS should
  # assign a public IPv4 address to this EC2 instance.
  #
  # This is required if we want to access the Nginx server
  # directly from the internet.
  associate_public_ip_address = true

  # user_data contains a shell script that runs
  # automatically when the EC2 instance starts
  # for the first time.
  user_data = <<-EOF
#!/bin/bash

# Installs Nginx on the EC2 instance.
#
# dnf is the package manager used by
# Amazon Linux 2023.
sudo dnf install nginx -y

# Enable Nginx to start automatically after reboot.
sudo systemctl enable nginx

# Starts the Nginx web server.
sudo systemctl start nginx
EOF

  # Not working
  # sudo yum install nginx -y

  # tags are key-value pairs used to identify
  # and organize AWS resources.
  tags = {

    # Name tag gives the EC2 instance
    # a human-readable name.
    Name = "nginx_server"
  }
}


