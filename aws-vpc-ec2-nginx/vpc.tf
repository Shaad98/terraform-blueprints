# ============================================================
# VPC
# ============================================================

# Creates a Virtual Private Cloud (VPC).
#
# A VPC is our private network inside AWS.
resource "aws_vpc" "my_vpc" {

  # cidr_block defines the IP address range
  # available inside the VPC.
  #
  # 10.0.0.0/16 provides a large private IP range.
  cidr_block = "10.0.0.0/16"

  # Tags help identify the VPC in the AWS Console.
  tags = {
    Name = "my_vpc"
  }
}


# ============================================================
# PRIVATE SUBNET
# ============================================================

# Creates a private subnet inside our VPC.
resource "aws_subnet" "private_subnet" {

  # vpc_id specifies which VPC this subnet
  # belongs to.
  vpc_id = aws_vpc.my_vpc.id

  # Defines the IP address range of this subnet.
  #
  # This subnet gets IP addresses from:
  # 10.0.1.0 - 10.0.1.255
  cidr_block = "10.0.1.0/24"

  # Name tag for identifying the subnet.
  tags = {
    Name = "private_subnet"
  }
}


# ============================================================
# PUBLIC SUBNET
# ============================================================

# Creates a public subnet inside our VPC.
resource "aws_subnet" "public_subnet" {

  # Connects this subnet to our VPC.
  vpc_id = aws_vpc.my_vpc.id

  # Defines the IP address range of this subnet.
  #
  # This subnet gets IP addresses from:
  # 10.0.2.0 - 10.0.2.255
  cidr_block = "10.0.2.0/24"

  # Name tag for identifying the subnet.
  tags = {
    Name = "public_subnet"
  }
}


# ============================================================
# INTERNET GATEWAY
# ============================================================

# Creates an Internet Gateway.
#
# An Internet Gateway allows resources in the VPC
# to communicate with the public internet.
resource "aws_internet_gateway" "my_igw" {

  # Attaches the Internet Gateway to our VPC.
  vpc_id = aws_vpc.my_vpc.id

  # Name tag for identifying the Internet Gateway.
  tags = {
    Name = "my_igw"
  }
}


# ============================================================
# ROUTE TABLE
# ============================================================

# Creates a route table for the VPC.
resource "aws_route_table" "my_rt" {

  # Specifies the VPC to which this route table belongs.
  vpc_id = aws_vpc.my_vpc.id

  # Defines a route inside the route table.
  route {

    # 0.0.0.0/0 means all IPv4 destinations.
    #
    # In simple terms:
    # "For any destination on the internet..."
    cidr_block = "0.0.0.0/0"

    # Sends this traffic through the Internet Gateway.
    #
    # This makes the associated subnet capable of
    # reaching the internet.
    gateway_id = aws_internet_gateway.my_igw.id
  }

  # Name tag for identifying the route table.
  tags = {
    Name = "my_rt"
  }
}


# ============================================================
# ROUTE TABLE ASSOCIATION
# ============================================================

# Associates the route table with the public subnet.
#
# Without this association, the public subnet would
# not use the routes defined in my_rt.
resource "aws_route_table_association" "public_sub" {

  # Specifies which route table should be associated.
  route_table_id = aws_route_table.my_rt.id

  # Specifies which subnet should use this route table.
  subnet_id = aws_subnet.public_subnet.id
}