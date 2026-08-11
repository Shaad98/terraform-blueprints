# Terraform AWS VPC + EC2 Nginx Lab

## 📌 Project Overview

This project creates a simple AWS infrastructure using **Terraform**:

```text
Internet
   |
   v
Internet Gateway
   |
   v
Public Route Table
   |
   v
Public Subnet
   |
   v
EC2 Instance
   |
   v
Nginx Web Server
   |
   v
HTTP :80
```

The project demonstrates the basic Terraform and AWS networking concepts required to launch a publicly accessible Nginx server.

---

# 1. What is Terraform?

**Terraform** is an Infrastructure as Code (IaC) tool.

Instead of manually creating AWS resources through the AWS Console, we describe the desired infrastructure in `.tf` files.

For example:

```hcl
resource "aws_instance" "nginx_server" {
  instance_type = "t3.micro"
}
```

Terraform reads this configuration and communicates with AWS to create the required resource.

### Main Terraform workflow

```text
Write .tf files
      |
      v
terraform init
      |
      v
terraform validate
      |
      v
terraform plan
      |
      v
terraform apply
      |
      v
AWS resources created
```

---

# 2. Terraform Provider

Terraform itself does not know how to create an EC2 instance.

The **AWS provider** gives Terraform the ability to communicate with AWS.

Example:

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

### Important attributes

### `source`

```hcl
source = "hashicorp/aws"
```

Specifies where Terraform should obtain the AWS provider.

### `version`

```hcl
version = "~> 6.0"
```

Specifies the acceptable provider version range.

---

# 3. AWS Provider Configuration

Example:

```hcl
provider "aws" {
  region = var.region
}
```

The provider tells Terraform which AWS region to use.

The region is stored in a variable:

```hcl
variable "region" {
  description = "AWS region where resources will be provisioned"
  default     = "us-east-1"
  type        = string
}
```

This is better than hard-coding the region in multiple places.

---

# 4. Terraform Variables

Variables make Terraform configurations reusable.

Example:

```hcl
variable "region" {
  description = "AWS region where resources will be provisioned"
  default     = "us-east-1"
  type        = string
}
```

### Attributes

| Attribute | Purpose |
|---|---|
| `description` | Explains what the variable is used for |
| `default` | Value used when no other value is provided |
| `type` | Defines the expected data type |

---

# 5. AWS VPC

A **VPC (Virtual Private Cloud)** is a logically isolated network in AWS.

Example:

```hcl
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "my_vpc"
  }
}
```

### `cidr_block`

```hcl
cidr_block = "10.0.0.0/16"
```

Defines the IP address range of the VPC.

The VPC can contain addresses such as:

```text
10.0.0.0
10.0.0.1
...
10.255.255.255
```

---

# 6. Subnets

A subnet is a smaller network inside a VPC.

This project has:

```text
VPC: 10.0.0.0/16
        |
        +-- Private Subnet: 10.0.1.0/24
        |
        +-- Public Subnet:  10.0.2.0/24
```

## Private Subnet

```hcl
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
}
```

## Public Subnet

```hcl
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
}
```

### Important concept

A subnet is not automatically public just because we call it `public_subnet`.

A subnet becomes publicly reachable when its route table provides a route to an **Internet Gateway**, and the resource also has a public IPv4 address where required.

---

# 7. Internet Gateway

An **Internet Gateway (IGW)** allows communication between the VPC and the public internet.

Example:

```hcl
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_igw"
  }
}
```

The Internet Gateway is attached to the VPC.

---

# 8. Route Table

A route table determines where network traffic should go.

Example:

```hcl
resource "aws_route_table" "my_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id  = aws_internet_gateway.my_igw.id
  }
}
```

The important route is:

```text
0.0.0.0/0
```

This means:

> Traffic destined for any IPv4 address outside the VPC should use this route.

The traffic is sent through:

```text
Internet Gateway
```

---

# 9. Route Table Association

Creating a route table is not enough.

The public subnet must be associated with it.

```hcl
resource "aws_route_table_association" "public_sub" {
  route_table_id = aws_route_table.my_rt.id
  subnet_id      = aws_subnet.public_subnet.id
}
```

This creates:

```text
Public Subnet
      |
      v
Public Route Table
      |
      v
Internet Gateway
      |
      v
Internet
```

---

# 10. Security Group

A Security Group acts as a virtual firewall for the EC2 instance.

Example:

```hcl
resource "aws_security_group" "nginx_sg" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

## Ingress

Ingress means **incoming traffic**.

```hcl
ingress {
  from_port   = 80
  to_port     = 80
  protocol     = "tcp"
  cidr_blocks  = ["0.0.0.0/0"]
}
```

This allows HTTP traffic from the internet.

```text
Internet
   |
   | TCP :80
   v
Security Group
   |
   v
EC2
   |
   v
Nginx
```

## Egress

Egress means **outgoing traffic**.

```hcl
egress {
  from_port   = 0
  to_port     = 0
  protocol     = "-1"
  cidr_blocks  = ["0.0.0.0/0"]
}
```

This allows the instance to make outbound connections.

---

# 11. EC2 Instance

The EC2 resource creates the virtual machine.

```hcl
resource "aws_instance" "nginx_server" {
  ami           = "ami-0bdc7d025135d7b49"
  instance_type = "t3.micro"

  subnet_id = aws_subnet.public_subnet.id

  vpc_security_group_ids = [
    aws_security_group.nginx_sg.id
  ]

  associate_public_ip_address = true
}
```

---

# 12. AMI

AMI means **Amazon Machine Image**.

```hcl
ami = "ami-0bdc7d025135d7b49"
```

An AMI provides the operating system and initial software required to boot the EC2 instance.

The AMI is **region-specific**.

Therefore, an AMI ID that works in one AWS region may not work in another region.

In this project the AMI is an Amazon Linux 2023 image.

---

# 13. Instance Type

```hcl
instance_type = "t3.micro"
```

Defines the compute resources of the EC2 instance.

For a learning project, `t3.micro` is a small instance suitable for basic testing.

---

# 14. Subnet ID

```hcl
subnet_id = aws_subnet.public_subnet.id
```

This tells AWS:

> Launch the EC2 instance inside this subnet.

The reference:

```hcl
aws_subnet.public_subnet.id
```

means:

```text
Resource type = aws_subnet
Resource name = public_subnet
Attribute     = id
```

---

# 15. Security Group Attachment

```hcl
vpc_security_group_ids = [
  aws_security_group.nginx_sg.id
]
```

This attaches the security group to the EC2 instance.

The EC2 therefore receives the inbound and outbound rules defined by that security group.

---

# 16. Public IP Address

```hcl
associate_public_ip_address = true
```

This requests a public IPv4 address for the EC2 instance.

The public IP allows users on the internet to access the server.

Example:

```text
Internet
   |
   v
Public IP
   |
   v
EC2
   |
   v
Nginx :80
```

Without appropriate public networking, the instance cannot be accessed directly from the internet.

---

# 17. User Data

One of the most important concepts in this project is **EC2 user data**.

```hcl
user_data = <<-EOF
#!/bin/bash

dnf install nginx -y
systemctl enable nginx
systemctl start nginx
EOF
```

User data is a startup script that cloud-init processes when the EC2 instance is initialized.

The purpose is to automatically configure the server.

Instead of manually doing:

```bash
sudo dnf install nginx -y
sudo systemctl start nginx
```

we let EC2 initialization do it automatically.

---

# 18. User Data Execution Flow

The process is:

```text
terraform apply
       |
       v
EC2 instance created
       |
       v
EC2 boots
       |
       v
cloud-init starts
       |
       v
user_data script executes
       |
       +----> dnf install nginx
       |
       +----> systemctl enable nginx
       |
       +----> systemctl start nginx
       |
       v
Nginx running
```

---

# 19. Shebang

The first line of the user-data script is:

```bash
#!/bin/bash
```

This is called a **shebang**.

It tells Linux that the script should be interpreted using Bash.

It should appear at the beginning of the generated script.

Correct:

```bash
#!/bin/bash
```

Avoid accidentally creating leading spaces before it when using a heredoc.

---

# 20. Terraform Heredoc

This syntax:

```hcl
user_data = <<-EOF
#!/bin/bash

dnf install nginx -y
systemctl enable nginx
systemctl start nginx
EOF
```

is called a **heredoc**.

It allows us to write a multiline string.

The markers:

```text
<<-EOF
...
EOF
```

define the beginning and end of the multiline string.

The closing `EOF` must be present.

---

# 21. Important Heredoc Lesson

Be careful with indentation.

The script should result in valid shell content such as:

```bash
#!/bin/bash
dnf install nginx -y
```

The `<<-EOF` syntax is designed to handle indentation using tabs, but relying on spaces can cause problems.

For simple EC2 user-data scripts, keeping the shell script left-aligned is clear and safe:

```hcl
user_data = <<-EOF
#!/bin/bash
dnf install nginx -y
systemctl enable nginx
systemctl start nginx
EOF
```

---

# 22. Why `dnf`?

The EC2 instance uses **Amazon Linux 2023**.

Amazon Linux 2023 uses DNF as its native package manager.

Therefore:

```bash
dnf install nginx -y
```

is the preferred command.

`yum` may also work because Amazon Linux 2023 provides compatibility behavior, but DNF is the native package manager.

---

# 23. Why `systemctl enable`?

```bash
systemctl enable nginx
```

configures Nginx to start automatically when the system boots.

Without `enable`, you can start Nginx manually:

```bash
systemctl start nginx
```

but it may not automatically start after a reboot.

The combination is:

```bash
systemctl enable nginx
systemctl start nginx
```

Meaning:

```text
enable = start automatically on boot
start  = start it right now
```

---

# 24. Checking Nginx

After connecting through SSH:

```bash
sudo systemctl status nginx
```

A successful server should show:

```text
Active: active (running)
```

You can also test locally:

```bash
curl localhost
```

If Nginx is working, HTML should be returned.

---

# 25. Cloud-init Logs

If user data doesn't work, check:

```bash
sudo tail -100 /var/log/cloud-init-output.log
```

This is extremely useful for debugging EC2 startup scripts.

Another useful command is:

```bash
sudo cat /var/lib/cloud/instance/user-data.txt
```

This shows the user-data that was supplied to the instance.

You can also check:

```bash
sudo cloud-init status
```

---

# 26. The Problem We Encountered

Initially, Nginx was not installed.

We saw:

```text
Unit nginx.service could not be found.
```

This means:

> The Nginx service does not exist on the machine.

We manually tested:

```bash
sudo yum install nginx -y
```

and it worked.

Therefore the package repository and Nginx installation itself were working.

The important clue was in:

```bash
sudo tail -100 /var/log/cloud-init-output.log
```

which showed:

```text
Failed to run module scripts-user
```

The problem was related to how the user-data shell script was being passed/executed, particularly the indentation around the shebang in the heredoc.

After correcting the user-data:

```hcl
user_data = <<-EOF
#!/bin/bash
dnf install nginx -y
systemctl enable nginx
systemctl start nginx
EOF
```

the EC2 automatically installed and started Nginx.

---

# 27. Terraform Resource Dependencies

Terraform automatically understands dependencies from resource references.

For example:

```hcl
subnet_id = aws_subnet.public_subnet.id
```

means the EC2 depends on the subnet.

Similarly:

```hcl
vpc_security_group_ids = [
  aws_security_group.nginx_sg.id
]
```

means the EC2 depends on the security group.

The dependency chain becomes approximately:

```text
VPC
 |
 +----> Subnets
 |
 +----> Internet Gateway
 |
 +----> Route Table
          |
          +----> Route Table Association

Security Group

Public Subnet + Security Group
             |
             v
            EC2
```

Terraform builds a dependency graph and creates resources in an appropriate order.

---

# 28. Explicit vs Implicit Dependencies

Terraform usually creates **implicit dependencies** automatically.

Example:

```hcl
subnet_id = aws_subnet.public_subnet.id
```

Terraform knows that the subnet must exist before the EC2.

An explicit dependency can be created using:

```hcl
depends_on = [
  aws_internet_gateway.my_igw
]
```

Use `depends_on` only when Terraform cannot determine the dependency automatically.

---

# 29. Terraform Outputs

An output exposes useful information after Terraform creates resources.

Example:

```hcl
output "link_to_access_nginx_server" {
  description = "URL to access the Nginx EC2 instance"
  value       = "http://${aws_instance.nginx_server.public_ip}"
}
```

After:

```bash
terraform apply
```

run:

```bash
terraform output
```

or:

```bash
terraform output link_to_access_nginx_server
```

Example:

```text
http://44.210.240.154
```

This makes it easy to access the Nginx server.

---

# 30. Terraform Init

```bash
terraform init
```

Initializes the Terraform working directory.

It downloads required providers and prepares Terraform.

Running it multiple times is safe.

For example:

```bash
terraform init
terraform init
```

does not create duplicate EC2 instances.

---

# 31. Terraform Validate

```bash
terraform validate
```

Checks whether the Terraform configuration is syntactically and structurally valid.

It does not create AWS resources.

Example:

```text
Success! The configuration is valid.
```

---

# 32. Terraform Plan

```bash
terraform plan
```

Shows what Terraform intends to create, change, or destroy.

It does not normally make those changes.

Example:

```text
+ create
~ update
- destroy
```

---

# 33. Terraform Apply

```bash
terraform apply
```

Applies the Terraform configuration and creates/updates AWS resources.

Typical workflow:

```text
terraform init
terraform validate
terraform plan
terraform apply
```

---

# 34. Terraform Destroy

```bash
terraform destroy
```

Deletes resources managed by Terraform.

For this project, that can include:

```text
EC2
Security Group
Subnet
Route Table
Route Table Association
Internet Gateway
VPC
```

Terraform determines the correct deletion order using its dependency graph.

---

# 35. What Happens to Manually Installed Software?

Suppose we SSH into EC2 and manually install:

```bash
sudo dnf install nginx -y
```

or:

```bash
sudo dnf install docker -y
```

These installations exist **inside the EC2 instance**.

If Terraform destroys the EC2:

```text
EC2 destroyed
      |
      +-- Nginx deleted
      +-- Docker deleted
      +-- Docker data deleted
      +-- OS deleted
```

The software doesn't need to be manually uninstalled first.

When a new EC2 is created, it is a new machine.

---

# 36. Important User Data Concept

User data normally runs during the instance's initial boot/initialization.

If you modify:

```hcl
user_data = <<-EOF
...
EOF
```

you should not assume that the script will simply rerun inside an already-running EC2 instance.

For a clean test, you can replace the instance:

```bash
terraform apply -replace=aws_instance.nginx_server
```

This creates a replacement instance so the initialization process runs again.

---

# 37. Public Nginx Access

For a browser request to reach Nginx, several things must work together:

```text
Browser
   |
   | HTTP :80
   v
EC2 Public IP
   |
   v
Internet Gateway
   |
   v
Route Table
   |
   v
Public Subnet
   |
   v
Security Group
   |
   | TCP :80 allowed
   v
EC2
   |
   v
Nginx :80
```

If any required part is missing, the browser may not reach Nginx.

---

# 38. Troubleshooting Checklist

If:

```text
http://<public-ip>
```

doesn't work, check in this order.

### 1. Is EC2 running?

```bash
aws ec2 describe-instances ...
```

or check the AWS Console.

### 2. Does Nginx exist?

```bash
sudo systemctl status nginx
```

If you see:

```text
Unit nginx.service could not be found.
```

Nginx is not installed.

### 3. Is Nginx running?

```bash
sudo systemctl status nginx
```

Look for:

```text
Active: active (running)
```

### 4. Does Nginx respond locally?

```bash
curl localhost
```

### 5. Is port 80 listening?

```bash
sudo ss -tulpn | grep :80
```

### 6. Does the Security Group allow TCP 80?

The rule should allow:

```text
TCP
Port: 80
Source: 0.0.0.0/0
```

### 7. Does the subnet have a route to the Internet Gateway?

Check the route table:

```text
0.0.0.0/0 -> Internet Gateway
```

### 8. Does the EC2 have a public IP?

Check:

```bash
terraform output
```

---

# 39. Project File Structure

A clean project can look like:

```text
aws-vpc-ec2-nginx/
│
├── main.tf
├── provider.tf
├── variable.tf
├── vpc.tf
├── ec2.tf
├── security_groups.tf
├── output.tf
│
├── terraform.tfstate
├── terraform.tfstate.backup
├── .terraform.lock.hcl
└── .terraform/
```

### `.tf` files

Contain Terraform configuration.

### `.terraform/`

Contains Terraform's working data and downloaded provider information.

### `.terraform.lock.hcl`

Locks provider versions/checksums.

### `terraform.tfstate`

Stores Terraform's state information about managed resources.

Do not casually edit the state file manually.

---

# 40. Git and Terraform State

For a learning project, you may commit the Terraform configuration files.

Usually do not commit:

```text
.terraform/
terraform.tfstate
terraform.tfstate.backup
```

A `.gitignore` can contain:

```gitignore
.terraform/
*.tfstate
*.tfstate.*
*.tfvars
```

Be careful with `.tfvars` because it may contain credentials or other secrets.

---

# 41. Key Concepts Learned

This project demonstrates:

- Infrastructure as Code
- Terraform providers
- Terraform variables
- Terraform resources
- Terraform outputs
- Terraform dependency graph
- AWS VPC
- CIDR blocks
- Subnets
- Public subnet concepts
- Internet Gateway
- Route tables
- Route table associations
- Security Groups
- EC2
- AMIs
- Instance types
- Public IPv4 addresses
- EC2 user data
- cloud-init
- Linux package management
- DNF
- systemd
- Nginx
- HTTP port 80
- Terraform lifecycle
- Terraform state
- Terraform destroy
- Debugging cloud-init

---

# 42. Final Architecture

```text
                         INTERNET
                            |
                            | HTTP :80
                            v
                   +------------------+
                   |  Internet Gateway |
                   +------------------+
                            |
                            v
                   +------------------+
                   |   Route Table    |
                   |  0.0.0.0/0 -> IGW|
                   +------------------+
                            |
                            v
              +----------------------------+
              |        Public Subnet        |
              |        10.0.2.0/24         |
              |                            |
              |   +--------------------+   |
              |   |        EC2         |   |
              |   |    t3.micro        |   |
              |   |                    |   |
              |   |      Nginx         |   |
              |   |       :80          |   |
              |   +--------------------+   |
              +----------------------------+
                            |
                            ^
                            |
                   Security Group
                   TCP :80 allowed
                            |
              +----------------------------+
              |            VPC             |
              |        10.0.0.0/16         |
              +----------------------------+
```

---

# 43. Most Important Lessons

### Lesson 1

Terraform is not just a tool to create EC2.

It can define the entire infrastructure:

```text
VPC
 ↓
Subnet
 ↓
Route Table
 ↓
Internet Gateway
 ↓
Security Group
 ↓
EC2
 ↓
Nginx
```

### Lesson 2

A public subnet is not enough.

You need the correct combination of:

```text
Public IP
+
Route to Internet Gateway
+
Security Group rule
+
Running application
```

### Lesson 3

`user_data` is extremely useful for bootstrapping EC2 instances.

Instead of manually configuring:

```bash
dnf install nginx
systemctl start nginx
```

Terraform can provide a startup script.

### Lesson 4

When automation fails, check the logs.

For EC2 user-data:

```bash
sudo tail -100 /var/log/cloud-init-output.log
```

This should become one of your first debugging commands.

### Lesson 5

Manual changes inside an EC2 are not the same as Terraform configuration.

If you manually install Docker or Nginx, Terraform does not automatically know how you configured them.

For repeatable infrastructure, put the configuration in:

```text
Terraform
+
user_data
or
configuration management
```

---

# 🚀 Useful Commands

```bash
terraform init
```

```bash
terraform fmt
```

```bash
terraform validate
```

```bash
terraform plan
```

```bash
terraform apply
```

```bash
terraform output
```

```bash
terraform state list
```

```bash
terraform apply -replace=aws_instance.nginx_server
```

```bash
terraform destroy
```

On EC2:

```bash
sudo systemctl status nginx
```

```bash
sudo systemctl start nginx
```

```bash
sudo systemctl enable nginx
```

```bash
curl localhost
```

```bash
sudo tail -100 /var/log/cloud-init-output.log
```

```bash
sudo cat /var/lib/cloud/instance/user-data.txt
```

```bash
sudo cloud-init status
```

---

# 🎯 Final Mental Model

Remember this:

```text
Terraform
   |
   | defines
   v
AWS Infrastructure
   |
   +---- VPC
   |
   +---- Subnet
   |
   +---- Internet Gateway
   |
   +---- Route Table
   |
   +---- Security Group
   |
   +---- EC2
             |
             | user_data
             v
        cloud-init
             |
             v
        install Nginx
             |
             v
        start Nginx
             |
             v
        HTTP :80
             |
             v
          Internet
```

This is the core DevOps/IaC pattern you just practiced: **define infrastructure as code → provision it → bootstrap the server automatically → expose the application → troubleshoot using logs → destroy and recreate reproducibly.**