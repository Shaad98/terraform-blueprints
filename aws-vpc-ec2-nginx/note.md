

# Terraform AWS Nginx Infrastructure

This project uses **Terraform** to provision an AWS infrastructure containing:

- AWS VPC
- Public Subnet
- Private Subnet
- Internet Gateway
- Route Table
- Route Table Association
- Security Group
- EC2 Instance
- Nginx Web Server
- Terraform Outputs

The main purpose of this project is to understand **Terraform, AWS networking, EC2, Security Groups, and Infrastructure as Code (IaC).**

---

# 1. What is Terraform?

Terraform is an **Infrastructure as Code (IaC)** tool developed by HashiCorp.

Instead of manually creating AWS resources from the AWS Console, we define infrastructure using configuration files.

Example:

```hcl
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}
````

Terraform reads this configuration and creates the VPC in AWS.

## Terraform Workflow

```text
Write Configuration
        ↓
terraform init
        ↓
terraform fmt
        ↓
terraform validate
        ↓
terraform plan
        ↓
terraform apply
        ↓
AWS Resources Created
```

---

# 2. Project Structure

```text
terraform-project/
│
├── main.tf
├── provider.tf
├── variable.tf
├── vpc.tf
├── ec2.tf
├── output.tf
└── README.md
```

Terraform automatically reads all `.tf` files in the same directory.

The files are separated to keep the project organized.

---

# 3. main.tf

The `main.tf` file contains the Terraform configuration and provider requirements.

```hcl
terraform {
  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

  }
}
```

## required_providers

This tells Terraform which providers are required by the project.

A **provider** is a plugin that allows Terraform to communicate with a particular platform.

For this project:

```text
Terraform
    ↓
AWS Provider
    ↓
AWS
```

---

# 4. provider.tf

The AWS provider allows Terraform to communicate with AWS.

```hcl
provider "aws" {
  region = var.region
}
```

The region is taken from the variable defined in `variable.tf`.

---

# 5. variable.tf

The `variable.tf` file defines input variables.

```hcl
variable "region" {

  description = "AWS region where resources will be provisioned"

  default = "us-east-1"

  type = string
}
```

## Variable

A variable allows us to avoid hardcoding values.

Instead of:

```hcl
region = "us-east-1"
```

we use:

```hcl
region = var.region
```

The default value is:

```text
us-east-1
```

We can later change the region without modifying the provider configuration.

---

# 6. What is a VPC?

VPC stands for:

**Virtual Private Cloud**

A VPC is a logically isolated network inside AWS.

Our VPC:

```hcl
resource "aws_vpc" "my_vpc" {

  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "my_vpc"
  }
}
```

The VPC uses:

```text
10.0.0.0/16
```

as its network range.

Conceptually:

```text
AWS
│
└── VPC
    │
    ├── Public Subnet
    │
    └── Private Subnet
```

---

# 7. What is CIDR?

CIDR stands for:

**Classless Inter-Domain Routing**

CIDR defines an IP address range.

Our VPC uses:

```text
10.0.0.0/16
```

The subnets divide this network into smaller networks.

```text
VPC
10.0.0.0/16
│
├── Private Subnet
│   10.0.1.0/24
│
└── Public Subnet
    10.0.2.0/24
```

---

# 8. What is a Subnet?

A subnet is a smaller network inside a VPC.

This project contains two subnets:

```text
VPC
│
├── Private Subnet
│   └── 10.0.1.0/24
│
└── Public Subnet
    └── 10.0.2.0/24
```

---

# 9. Private Subnet

The private subnet is:

```hcl
resource "aws_subnet" "private_subnet" {

  vpc_id = aws_vpc.my_vpc.id

  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "private_subnet"
  }
}
```

The subnet uses:

```text
10.0.1.0/24
```

It is intended for private resources.

---

# 10. Public Subnet

The public subnet is:

```hcl
resource "aws_subnet" "public_subnet" {

  vpc_id = aws_vpc.my_vpc.id

  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "public_subnet"
  }
}
```

The EC2 instance is launched inside this subnet.

---

# 11. What Makes a Subnet Public?

Simply naming a subnet:

```text
public_subnet
```

does **not** make it public.

A subnet becomes effectively public when its route table contains a route to an Internet Gateway.

```text
Public Subnet
      ↓
Route Table
      ↓
0.0.0.0/0
      ↓
Internet Gateway
      ↓
Internet
```

The EC2 instance also needs a public IP to be directly reachable from the internet.

---

# 12. Internet Gateway

An Internet Gateway allows communication between a VPC and the internet.

Terraform configuration:

```hcl
resource "aws_internet_gateway" "my_igw" {

  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_igw"
  }
}
```

The Internet Gateway is attached to our VPC.

```text
VPC
 │
 └── Internet Gateway
          │
          ↓
       Internet
```

---

# 13. Route Table

A route table tells AWS where network traffic should go.

Our route table:

```hcl
resource "aws_route_table" "my_rt" {

  vpc_id = aws_vpc.my_vpc.id

  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "my_rt"
  }
}
```

The important route is:

```text
0.0.0.0/0 → Internet Gateway
```

`0.0.0.0/0` means:

**Any IPv4 destination.**

So this route means:

```text
For any internet destination
        ↓
Send traffic to Internet Gateway
```

---

# 14. Route Table Association

Creating a route table is not enough.

The route table needs to be associated with a subnet.

```hcl
resource "aws_route_table_association" "public_sub" {

  route_table_id = aws_route_table.my_rt.id

  subnet_id = aws_subnet.public_subnet.id
}
```

This means:

```text
Route Table
     ↓
Public Subnet
```

The public subnet now uses the routes defined in the route table.

---

# 15. Security Group

A Security Group acts like a virtual firewall for AWS resources such as EC2.

```hcl
resource "aws_security_group" "nginx_sg" {

  vpc_id = aws_vpc.my_vpc.id
}
```

It controls:

* Inbound traffic
* Outbound traffic

Conceptually:

```text
Internet
    ↓
Security Group
    ↓
EC2
```

---

# 16. Ingress

Ingress means:

**Incoming traffic**

Our ingress rule:

```hcl
ingress {

  from_port = 80

  to_port = 80

  protocol = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
}
```

This allows TCP traffic on port `80`.

Port `80` is the default port for HTTP.

Therefore:

```text
Internet
    │
    │ TCP :80
    ↓
Security Group
    ↓
EC2
```

---

# 17. What is 0.0.0.0/0?

```text
0.0.0.0/0
```

means:

**All IPv4 addresses.**

Therefore:

```hcl
cidr_blocks = ["0.0.0.0/0"]
```

allows traffic from anywhere on the internet.

For this learning project, this allows anyone to access the Nginx HTTP server.

In production, access should generally be restricted where possible.

---

# 18. Egress

Egress means:

**Outgoing traffic**

Our egress rule:

```hcl
egress {

  from_port = 0

  to_port = 0

  protocol = -1

  cidr_blocks = ["0.0.0.0/0"]
}
```

This allows outbound traffic from the EC2 instance.

```text
EC2
 ↓
Outbound Traffic
 ↓
Internet
```

`protocol = -1` means all protocols.

---

# 19. EC2

EC2 stands for:

**Elastic Compute Cloud**

EC2 provides virtual servers in AWS.

Our EC2 instance:

```hcl
resource "aws_instance" "nginx_server" {

  ami = "ami-0bdc7d025135d7b49"

  instance_type = "t3.micro"

  subnet_id = aws_subnet.public_subnet.id

  vpc_security_group_ids = [
    aws_security_group.nginx_sg.id
  ]

  associate_public_ip_address = true
}
```

---

# 20. What is an AMI?

AMI stands for:

**Amazon Machine Image**

An AMI is a template used to launch an EC2 instance.

It contains information such as:

* Operating system
* System configuration
* Software configuration

Our EC2 uses:

```hcl
ami = "ami-0bdc7d025135d7b49"
```

The AMI ID is region-specific.

An AMI available in one AWS region may not be available in another region.

---

# 21. Instance Type

The instance type defines the hardware configuration of the EC2 instance.

Our instance type is:

```hcl
instance_type = "t3.micro"
```

The instance type determines resources such as:

* CPU
* Memory
* Network performance

For a small learning project, a small instance type can be sufficient.

---

# 22. Subnet ID

The EC2 instance is launched into the public subnet:

```hcl
subnet_id = aws_subnet.public_subnet.id
```

This creates the relationship:

```text
EC2
 ↓
Public Subnet
 ↓
VPC
```

Terraform automatically understands that the subnet must exist before creating the EC2 instance.

---

# 23. Security Group ID

The EC2 instance uses our Nginx security group:

```hcl
vpc_security_group_ids = [
  aws_security_group.nginx_sg.id
]
```

This means:

```text
EC2
 ↓
nginx_sg
 ↓
Port 80 allowed
```

---

# 24. Public IP

Our EC2 configuration contains:

```hcl
associate_public_ip_address = true
```

This allows the EC2 instance to receive a public IPv4 address.

The public IP can then be used to access Nginx.

```text
Browser
   ↓
EC2 Public IP
   ↓
Security Group
   ↓
Port 80
   ↓
Nginx
```

---

# 25. user_data

`user_data` is a script that runs when the EC2 instance is initialized.

Our configuration:

```hcl
user_data = <<-EOF

#!/bin/bash

sudo yum install nginx -y

sudo systemctl start nginx

EOF
```

The script does two important things.

## Install Nginx

```bash
sudo yum install nginx -y
```

## Start Nginx

```bash
sudo systemctl start nginx
```

Therefore, Terraform can create the EC2 instance and automatically install Nginx.

---

# 26. What is Nginx?

Nginx is a web server.

After Nginx starts, it listens for HTTP requests.

HTTP normally uses:

```text
Port 80
```

When we access:

```text
http://EC2_PUBLIC_IP
```

the request reaches Nginx.

```text
Browser
   ↓
Internet
   ↓
Internet Gateway
   ↓
Route Table
   ↓
Public Subnet
   ↓
Security Group
   ↓
EC2
   ↓
Nginx
   ↓
HTTP Response
   ↓
Browser
```

---

# 27. Terraform Resource Syntax

Terraform resources generally follow this structure:

```hcl
resource "RESOURCE_TYPE" "RESOURCE_NAME" {

  attribute = value
}
```

Example:

```hcl
resource "aws_vpc" "my_vpc" {

  cidr_block = "10.0.0.0/16"
}
```

Here:

```text
resource
    ↓
Resource block

aws_vpc
    ↓
Resource type

my_vpc
    ↓
Terraform resource name

cidr_block
    ↓
Attribute

10.0.0.0/16
    ↓
Attribute value
```

---

# 28. Terraform Resource References

Terraform resources can reference other resources.

Example:

```hcl
vpc_id = aws_vpc.my_vpc.id
```

This means:

```text
aws_vpc
    ↓
my_vpc
    ↓
id
```

Another example:

```hcl
subnet_id = aws_subnet.public_subnet.id
```

This means:

```text
aws_subnet
    ↓
public_subnet
    ↓
id
```

Terraform uses these references to understand dependencies.

---

# 29. Terraform Dependency

For example:

```hcl
resource "aws_subnet" "public_subnet" {

  vpc_id = aws_vpc.my_vpc.id
}
```

Terraform understands:

```text
VPC
 ↓
Subnet
```

The VPC must exist before the subnet can be created.

Similarly:

```text
VPC
 ↓
Subnet
 ↓
EC2
```

Terraform automatically handles this dependency.

---

# 30. Outputs

The `output.tf` file displays useful information after infrastructure is created.

Example:

```hcl
output "ec2_public_ip" {

  description = "Public IP address of the Nginx EC2 instance"

  value = aws_instance.nginx_server.public_ip
}
```

After:

```bash
terraform apply
```

Terraform can display:

```text
ec2_public_ip = "54.xx.xx.xx"
```

We can also retrieve it using:

```bash
terraform output ec2_public_ip
```

---

# 31. Useful Terraform Outputs

This project outputs values such as:

```text
EC2 Instance ID
EC2 Public IP
EC2 Public DNS
EC2 Instance Name

VPC ID
VPC CIDR Block

Public Subnet ID
Public Subnet CIDR Block
Private Subnet ID

Security Group ID
Internet Gateway ID
Route Table ID
```

---

# 32. Terraform Commands

## Initialize

```bash
terraform init
```

Downloads the required providers and initializes the Terraform working directory.

---

## Format

```bash
terraform fmt
```

Formats Terraform configuration files.

---

## Validate

```bash
terraform validate
```

Checks whether the Terraform configuration is syntactically valid.

Expected result:

```text
Success! The configuration is valid.
```

---

## Plan

```bash
terraform plan
```

Shows what Terraform plans to create, modify, or destroy.

Example:

```text
+ create aws_vpc
+ create aws_subnet
+ create aws_instance
+ create aws_security_group
```

`+` means the resource will be created.

---

## Apply

```bash
terraform apply
```

Creates the infrastructure in AWS.

Terraform normally asks for confirmation:

```text
Do you want to perform these actions?
```

Enter:

```text
yes
```

---

## Destroy

```bash
terraform destroy
```

Deletes the infrastructure managed by Terraform.

Use this carefully.

---

# 33. Complete Architecture

```text
                         INTERNET
                            │
                            │ HTTP :80
                            ↓
                  ┌───────────────────┐
                  │  Internet Gateway │
                  └─────────┬─────────┘
                            │
                            ↓
                  ┌───────────────────┐
                  │    Route Table    │
                  │                   │
                  │ 0.0.0.0/0 → IGW  │
                  └─────────┬─────────┘
                            │
                            ↓
        ┌────────────────────────────────────┐
        │               VPC                  │
        │            10.0.0.0/16             │
        │                                    │
        │   ┌────────────────────────────┐   │
        │   │       Public Subnet        │   │
        │   │        10.0.2.0/24         │   │
        │   │                            │   │
        │   │  ┌──────────────────────┐  │   │
        │   │  │    Security Group    │  │   │
        │   │  │      TCP :80         │  │   │
        │   │  └──────────┬───────────┘  │   │
        │   │             │              │   │
        │   │             ↓              │   │
        │   │       ┌─────────────┐      │   │
        │   │       │ EC2 Instance│      │   │
        │   │       │  t3.micro   │      │   │
        │   │       │    Nginx    │      │   │
        │   │       └─────────────┘      │   │
        │   └────────────────────────────┘   │
        │                                    │
        │   ┌────────────────────────────┐   │
        │   │       Private Subnet       │   │
        │   │        10.0.1.0/24         │   │
        │   └────────────────────────────┘   │
        │                                    │
        └────────────────────────────────────┘
```

---

# 34. Request Flow

When a user opens:

```text
http://EC2_PUBLIC_IP
```

the request follows:

```text
Browser
   ↓
Internet
   ↓
Internet Gateway
   ↓
Route Table
   ↓
Public Subnet
   ↓
Security Group
   ↓
Port 80
   ↓
EC2
   ↓
Nginx
   ↓
HTTP Response
   ↓
Browser
```

---

# 35. Important Concepts to Remember

## VPC

```text
VPC = Network
```

A VPC is the private network in AWS.

---

## Subnet

```text
Subnet = Smaller network inside VPC
```

---

## Internet Gateway

```text
Internet Gateway = Connection between VPC and Internet
```

---

## Route Table

```text
Route Table = Defines where network traffic goes
```

---

## Security Group

```text
Security Group = Virtual firewall
```

---

## EC2

```text
EC2 = Virtual server
```

---

## AMI

```text
AMI = Template used to launch EC2
```

---

## Nginx

```text
Nginx = Web server
```

---

## Output

```text
Output = Displays useful Terraform values
```

---

# 36. Public Subnet vs Public IP

These are two different concepts.

### Public Subnet

A subnet whose routing allows communication with the internet through an Internet Gateway.

### Public IP

An IP address assigned to the EC2 instance that allows it to be reachable from the public internet, subject to routing and security rules.

For our EC2 to be reachable:

```text
Public Subnet
      +
Internet Gateway
      +
Route Table
      +
Public IP
      +
Security Group allowing TCP :80
      ↓
Internet-accessible Nginx
```

---

# 37. Why Terraform is Useful

Without Terraform, we could manually create the resources using the AWS Console.

```text
VPC
 ↓
Subnet
 ↓
Internet Gateway
 ↓
Route Table
 ↓
Security Group
 ↓
EC2
 ↓
Nginx
```

With Terraform, the infrastructure is represented as code.

Benefits:

* Infrastructure is reproducible
* Infrastructure can be version controlled
* Infrastructure can be reviewed using Git
* Infrastructure can be created consistently
* Manual configuration is reduced
* Infrastructure can be recreated
* Changes can be reviewed using `terraform plan`

---

# 38. Final Infrastructure

The project creates:

```text
AWS
│
└── VPC
    │
    ├── Public Subnet
    │   │
    │   └── Nginx EC2
    │
    ├── Private Subnet
    │
    ├── Internet Gateway
    │
    ├── Route Table
    │
    ├── Route Table Association
    │
    └── Security Group
```

The Nginx server can be accessed using:

```text
http://<EC2_PUBLIC_IP>
```

The public IP can be retrieved with:

```bash
terraform output ec2_public_ip
```

---

# 39. Cleanup

When the lab is finished, destroy the infrastructure to avoid unnecessary AWS charges:

```bash
terraform destroy
```

Confirm with:

```text
yes
```

Terraform will remove the resources it created.

---

# 40. Quick Revision

```text
Terraform
    ↓
AWS Provider
    ↓
VPC
    ↓
Subnets
    ↓
Internet Gateway
    ↓
Route Table
    ↓
Security Group
    ↓
EC2
    ↓
Nginx
    ↓
Port 80
    ↓
Internet
```

## Main Idea

> Terraform defines infrastructure as code, AWS creates the infrastructure, networking controls how resources communicate, Security Groups control traffic, and EC2 runs the Nginx web server.



