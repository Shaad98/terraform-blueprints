# Creates a Security Group for the Nginx EC2 instance.
resource "aws_security_group" "nginx_sg" {

  # vpc_id specifies which VPC this security group
  # belongs to.
  #
  # aws_vpc.my_vpc.id gets the ID of the VPC
  # created in vpc.tf.
  vpc_id = aws_vpc.my_vpc.id

  # ingress defines inbound traffic rules.
  #
  # It controls what traffic is allowed INTO
  # the EC2 instance.
  ingress {

    # from_port specifies the starting port.
    from_port = 80

    # to_port specifies the ending port.
    to_port = 80

    # protocol specifies the network protocol.
    # tcp is used by HTTP.
    protocol = "tcp"

    # cidr_blocks specifies which IP addresses
    # are allowed to access port 80.
    #
    # 0.0.0.0/0 means ANY IPv4 address on the internet.
    cidr_blocks = ["0.0.0.0/0"]
  }

  # egress defines outbound traffic rules.
  #
  # It controls what traffic is allowed OUT
  # of the EC2 instance.
  egress {

    # from_port = 0 means start from port 0.
    from_port = 0

    # to_port = 0 is used with protocol = -1
    # to allow all outbound ports.
    to_port = 0

    # -1 means all protocols.
    protocol = -1

    # Allows outbound traffic to any IPv4 address.
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Tags used to identify the security group.
  tags = {
    Name = "nginx_sg"
  }
}