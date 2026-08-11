# ============================================================
# EC2 OUTPUTS
# ============================================================

# Displays the EC2 instance ID.
#
# Example:
# i-0123456789abcdef
output "ec2_instance_id" {

  # Description explains what this output represents.
  description = "ID of the Nginx EC2 instance"

  # Gets the ID of the EC2 instance.
  value = aws_instance.nginx_server.id
}


# Displays the public IP address of the EC2 instance.
#
# You can use this IP in your browser:
# http://<public-ip>
output "ec2_public_ip" {

  description = "Public IP address of the Nginx EC2 instance"

  # public_ip contains the public IPv4 address
  # assigned to the EC2 instance.
  value = aws_instance.nginx_server.public_ip
}

# Open Nginx default page hosted globally
output "link_to_access_nginx_server" {

  description = "URL to access the Nginx EC2 instance"

  value = "http://${aws_instance.nginx_server.public_ip}"
}

# Displays the public DNS name of the EC2 instance.
#
# Example:
# ec2-xx-xx-xx-xx.compute-1.amazonaws.com
output "ec2_public_dns" {

  description = "Public DNS name of the Nginx EC2 instance"

  # public_dns gives the AWS-generated public DNS name.
  value = aws_instance.nginx_server.public_dns
}


# Displays the Name tag of the EC2 instance.
output "ec2_instance_name" {

  description = "Name of the Nginx EC2 instance"

  # tags["Name"] gets the value of the Name tag.
  value = aws_instance.nginx_server.tags["Name"]
}


# ============================================================
# VPC OUTPUT
# ============================================================

# Displays the ID of our VPC.
output "vpc_id" {

  description = "ID of the VPC"

  # Gets the ID of the VPC created in vpc.tf.
  value = aws_vpc.my_vpc.id
}


# Displays the CIDR block of our VPC.
output "vpc_cidr_block" {

  description = "CIDR block of the VPC"

  value = aws_vpc.my_vpc.cidr_block
}


# ============================================================
# SUBNET OUTPUTS
# ============================================================

# Displays the ID of the public subnet.
output "public_subnet_id" {

  description = "ID of the public subnet"

  value = aws_subnet.public_subnet.id
}


# Displays the CIDR block of the public subnet.
output "public_subnet_cidr_block" {

  description = "CIDR block of the public subnet"

  value = aws_subnet.public_subnet.cidr_block
}


# Displays the ID of the private subnet.
output "private_subnet_id" {

  description = "ID of the private subnet"

  value = aws_subnet.private_subnet.id
}


# ============================================================
# SECURITY GROUP OUTPUT
# ============================================================

# Displays the ID of the Nginx security group.
output "nginx_security_group_id" {

  description = "ID of the Nginx security group"

  value = aws_security_group.nginx_sg.id
}


# ============================================================
# INTERNET GATEWAY OUTPUT
# ============================================================

# Displays the ID of the Internet Gateway.
output "internet_gateway_id" {

  description = "ID of the Internet Gateway"

  value = aws_internet_gateway.my_igw.id
}


# ============================================================
# ROUTE TABLE OUTPUT
# ============================================================

# Displays the ID of the public route table.
output "public_route_table_id" {

  description = "ID of the public route table"

  value = aws_route_table.my_rt.id
}