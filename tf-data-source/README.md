# Terraform Data Sources – Launch EC2 Using Existing AWS Infrastructure

This project demonstrates how to use **Terraform Data Sources** to read existing AWS infrastructure and use the retrieved information to launch a new EC2 instance.

Terraform does **not** create the VPC, subnet, security group, or AMI.

Instead, Terraform:

1. Finds an existing Amazon Linux AMI.
2. Finds an existing VPC using its `Name` tag.
3. Finds an existing subnet inside that VPC.
4. Finds an existing security group inside that VPC.
5. Uses all of these existing resources to launch a new EC2 instance.

---

# 📌 Architecture

```text
                         AWS
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
        ▼                 ▼                 ▼
   Amazon Linux       Existing VPC    Existing SG
       AMI                 │
                           │
                           ▼
                    Existing Subnet
                           │
                           │
                           ▼
                    New EC2 Instance
                       t3.micro
```

Terraform only creates:

```text
EC2 Instance
```

The following resources already exist in AWS:

```text
AMI
VPC
Subnet
Security Group
```

---

# 📁 Project Structure

```text
tf-data-source/
│
├── main.tf
└── README.md
```

---

# ⚙️ Prerequisites / Required Setup

Before running this Terraform configuration, you need an AWS environment with some existing resources.

## 1. AWS Account

You need an AWS account with permission to:

* Read VPC information
* Read subnet information
* Read security groups
* Read AMIs
* Create EC2 instances
* Read EC2 information

The IAM user or role running Terraform should have appropriate EC2/VPC permissions.

For a learning environment, you can use an IAM identity with sufficient EC2 permissions.

---

# 2. AWS Credentials

Terraform needs credentials to communicate with AWS.

You can configure them using the AWS CLI:

```bash
aws configure
```

You will be asked for:

```text
AWS Access Key ID
AWS Secret Access Key
Default region name
Default output format
```

For this project, the region is:

```text
us-east-1
```

You can verify your credentials with:

```bash
aws sts get-caller-identity
```

If this command successfully returns your AWS account information, Terraform can generally use the same credentials.

> Never put AWS access keys directly inside `main.tf` or commit them to Git.

---

# 3. Terraform Installation

Terraform must be installed.

Check:

```bash
terraform version
```

This project uses the AWS provider:

```hcl
version = "~> 6.0"
```

---

# 4. AWS Region

This project uses:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

Therefore, the existing VPC, subnet, and security group should be in:

```text
us-east-1
```

The AMI is also searched in:

```text
us-east-1
```

AWS AMIs are generally region-specific, so make sure the resources and AMI are being looked up in the intended region.

---

# 5. Existing VPC

You need an existing VPC in AWS.

The VPC must have this tag:

```text
Key:   Name
Value: my-vpc
```

For example:

```text
VPC
├── VPC ID: vpc-xxxxxxxx
├── CIDR: 10.0.0.0/16
└── Tags
    └── Name = my-vpc
```

Terraform searches for it using:

```hcl
data "aws_vpc" "existing_vpc" {
  filter {
    name   = "tag:Name"
    values = ["my-vpc"]
  }
}
```

Terraform does not create this VPC.

It only reads it.

---

# 6. Existing Subnet

You need an existing subnet inside the VPC.

The subnet must have:

```text
Key:   Name
Value: my-public-subnet
```

For example:

```text
Subnet
├── Subnet ID: subnet-xxxxxxxx
├── VPC: vpc-xxxxxxxx
├── CIDR: 10.0.1.0/24
└── Tags
    └── Name = my-public-subnet
```

Terraform searches for it using:

```hcl
data "aws_subnet" "existing_subnet" {
  vpc_id = data.aws_vpc.existing_vpc.id

  filter {
    name   = "tag:Name"
    values = ["my-public-subnet"]
  }
}
```

Notice:

```hcl
vpc_id = data.aws_vpc.existing_vpc.id
```

This ensures that Terraform looks for the subnet **inside the VPC that it already found**.

---

# 7. Existing Security Group

You also need an existing security group inside the same VPC.

It must have:

```text
Key:   Name
Value: my-web-sg
```

Example:

```text
Security Group
├── SG ID: sg-xxxxxxxx
├── VPC: vpc-xxxxxxxx
└── Tags
    └── Name = my-web-sg
```

Terraform searches for it using:

```hcl
data "aws_security_group" "existing_sg" {
  vpc_id = data.aws_vpc.existing_vpc.id

  filter {
    name   = "tag:Name"
    values = ["my-web-sg"]
  }
}
```

---

# 8. Security Group Rules

The existing security group should have the appropriate inbound and outbound rules.

For example, if you want to access a web server:

```text
Inbound
--------------------------------
HTTP   TCP   80    <your source>
SSH    TCP   22    <your source>

Outbound
--------------------------------
All traffic
```

Terraform is **not creating or modifying these rules** in this project.

It is only finding the existing security group and attaching it to the EC2 instance.

---

# 9. Existing AMI

The configuration searches for an Amazon Linux 2023 AMI:

```hcl
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
```

Terraform searches AWS and selects the most recent matching AMI.

You don't need to manually copy an AMI ID such as:

```text
ami-xxxxxxxxxxxxxxxxx
```

Instead Terraform obtains it dynamically.

---

# 🔍 Understanding the AMI Data Source

The following:

```hcl
data "aws_ami" "amazon_linux" {
```

means:

```text
data
 ↓
AWS AMI
 ↓
local name = amazon_linux
```

The AMI ID can then be accessed using:

```hcl
data.aws_ami.amazon_linux.id
```

The AMI name can be accessed using:

```hcl
data.aws_ami.amazon_linux.name
```

---

# 🔍 Understanding the VPC Data Source

```hcl
data "aws_vpc" "existing_vpc" {
  filter {
    name   = "tag:Name"
    values = ["my-vpc"]
  }
}
```

Terraform searches AWS for:

```text
Name = my-vpc
```

After finding it, its ID can be accessed using:

```hcl
data.aws_vpc.existing_vpc.id
```

---

# 🔍 Understanding the Subnet Data Source

```hcl
data "aws_subnet" "existing_subnet" {
  vpc_id = data.aws_vpc.existing_vpc.id

  filter {
    name   = "tag:Name"
    values = ["my-public-subnet"]
  }
}
```

Terraform searches for:

```text
Name = my-public-subnet
```

inside:

```text
VPC = data.aws_vpc.existing_vpc.id
```

Its ID can be accessed using:

```hcl
data.aws_subnet.existing_subnet.id
```

---

# 🔍 Understanding the Security Group Data Source

```hcl
data "aws_security_group" "existing_sg" {
  vpc_id = data.aws_vpc.existing_vpc.id

  filter {
    name   = "tag:Name"
    values = ["my-web-sg"]
  }
}
```

Terraform searches for the security group:

```text
Name = my-web-sg
```

inside the existing VPC.

Its ID can be accessed using:

```hcl
data.aws_security_group.existing_sg.id
```

---

# 🚀 Launching the EC2 Instance

The EC2 resource is:

```hcl
resource "aws_instance" "mywebserver01" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  subnet_id = data.aws_subnet.existing_subnet.id

  vpc_security_group_ids = [
    data.aws_security_group.existing_sg.id
  ]

  tags = {
    Name = "MyWebServer01"
  }
}
```

The important part is that the EC2 doesn't contain hard-coded IDs.

Instead:

### AMI

```hcl
ami = data.aws_ami.amazon_linux.id
```

### Subnet

```hcl
subnet_id = data.aws_subnet.existing_subnet.id
```

### Security Group

```hcl
vpc_security_group_ids = [
  data.aws_security_group.existing_sg.id
]
```

Terraform dynamically retrieves these values from AWS.

---

# 🔄 Complete Data Flow

```text
1. Find Amazon Linux AMI
        │
        ▼
data.aws_ami.amazon_linux.id
        │
        │
2. Find VPC using Name tag
        │
        ▼
data.aws_vpc.existing_vpc.id
        │
        │
3. Find subnet inside VPC
        │
        ▼
data.aws_subnet.existing_subnet.id
        │
        │
4. Find security group inside VPC
        │
        ▼
data.aws_security_group.existing_sg.id
        │
        │
        └──────────────┐
                       ▼
                EC2 Instance
                  t3.micro
```

---

# 🏷️ Tags Used

The following tags are expected to already exist in AWS:

| Resource       | Tag Key | Tag Value          |
| -------------- | ------- | ------------------ |
| VPC            | `Name`  | `my-vpc`           |
| Subnet         | `Name`  | `my-public-subnet` |
| Security Group | `Name`  | `my-web-sg`        |

The EC2 instance is tagged by Terraform:

```hcl
tags = {
  Name = "MyWebServer01"
}
```

So there is an important difference:

### Existing infrastructure

Terraform **reads** these tags:

```text
my-vpc
my-public-subnet
my-web-sg
```

### New EC2

Terraform **creates**:

```text
MyWebServer01
```

---

# 🧠 Resource vs Data Source

This project demonstrates an important Terraform distinction.

## Data Source

```hcl
data "aws_vpc" "existing_vpc" {
  ...
}
```

Means:

> Find/read an existing VPC.

Terraform does not create it.

## Resource

```hcl
resource "aws_instance" "mywebserver01" {
  ...
}
```

Means:

> Terraform should create and manage this EC2 instance.

Therefore:

```text
data     → read existing infrastructure
resource → create/manage infrastructure
```

---

# 🛠️ Terraform Commands

## 1. Initialize

Run this from the project directory:

```bash
terraform init
```

This downloads the AWS provider.

---

## 2. Format

```bash
terraform fmt
```

Formats the Terraform configuration.

---

## 3. Validate

```bash
terraform validate
```

Checks the Terraform configuration.

Expected result:

```text
Success! The configuration is valid.
```

---

## 4. Plan

```bash
terraform plan
```

Terraform will:

* Search for the Amazon Linux AMI
* Search for the VPC
* Search for the subnet
* Search for the security group
* Plan creation of the EC2

You should see something similar to:

```text
data.aws_ami.amazon_linux: Read complete
data.aws_vpc.existing_vpc: Read complete
data.aws_subnet.existing_subnet: Read complete
data.aws_security_group.existing_sg: Read complete

Plan: 1 to add, 0 to change, 0 to destroy.
```

This means Terraform is planning to create only the EC2 instance.

---

# 5. Apply

Once you have verified the plan:

```bash
terraform apply
```

Terraform will create the EC2 instance using:

```text
Amazon Linux AMI
       +
Existing VPC
       +
Existing Subnet
       +
Existing Security Group
       ↓
New EC2 Instance
```

---

# 6. View Outputs

```bash
terraform output
```

You can also retrieve an individual output:

```bash
terraform output ami_id
```

---

# 7. Destroy

```bash
terraform destroy
```

This will destroy the EC2 instance created by Terraform.

It will **not destroy**:

* Existing VPC
* Existing subnet
* Existing security group
* Amazon Linux AMI

because those are being accessed through data sources.

---

# 📤 Outputs

The configuration provides:

```hcl
output "ami_id" {
  value = data.aws_ami.amazon_linux.id
}

output "ami_name" {
  value = data.aws_ami.amazon_linux.name
}

output "vpc_id" {
  value = data.aws_vpc.existing_vpc.id
}

output "subnet_id" {
  value = data.aws_subnet.existing_subnet.id
}

output "security_group_id" {
  value = data.aws_security_group.existing_sg.id
}

output "ec2_public_ip" {
  value = aws_instance.mywebserver01.public_ip
}
```

These outputs make it easy to verify which existing resources Terraform found and what EC2 was created.

---

# ⚠️ Common Problems

## VPC Not Found

If Terraform reports that no VPC was found, check:

```text
Name = my-vpc
```

Make sure the tag value exactly matches.

---

## Subnet Not Found

Check:

```text
Name = my-public-subnet
```

and make sure the subnet belongs to the VPC that Terraform found.

---

## Security Group Not Found

Check:

```text
Name = my-web-sg
```

and make sure the security group belongs to the selected VPC.

---

## AMI Not Found

Make sure the AMI filter matches an Amazon Linux 2023 image available in:

```text
us-east-1
```

You can verify the selected AMI during:

```bash
terraform plan
```

---

## Wrong AWS Region

The provider currently uses:

```hcl
region = "us-east-1"
```

If your existing VPC, subnet, and security group are in another region, change the provider region accordingly.

---

# 🎯 Main Learning

This project demonstrates a very common real-world Terraform pattern:

```text
Existing AWS Infrastructure
          │
          │ Terraform Data Sources
          ▼
     Read Existing IDs
          │
          ▼
   New Terraform Resource
          │
          ▼
      EC2 Instance
```

Instead of hard-coding:

```hcl
ami           = "ami-123456"
subnet_id     = "subnet-123456"
security_group = "sg-123456"
```

Terraform dynamically discovers these resources from AWS.

This makes the configuration more reusable and demonstrates how Terraform can work with infrastructure that was created **outside Terraform**.
