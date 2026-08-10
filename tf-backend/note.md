# 🚀 Terraform AWS EC2 with Remote State Backend

This project demonstrates how to provision an **AWS EC2 instance using Terraform** while storing the Terraform state file remotely in an **Amazon S3 bucket**.

## 📌 What This Project Demonstrates

* Terraform AWS provider configuration
* Terraform Random provider
* AWS EC2 instance creation
* Terraform variables
* Terraform outputs
* Dynamic EC2 `Name` tag using `random_id`
* Remote Terraform state management using an S3 backend
* Separation of Terraform configuration into multiple `.tf` files

---

## 📁 Project Structure

```text
terraform-ec2-project/
│
├── main.tf
├── variable.tf
├── provider.tf
├── output.tf
└── README.md
```

---

# 1. `main.tf`

The `main.tf` file contains:

* Required Terraform providers
* Remote S3 backend configuration
* Random ID resource
* AWS EC2 instance resource

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.9.0"
    }
  }

  backend "s3" {
    # S3 bucket where the Terraform state file is stored
    bucket = "mybucket-terraform-backend-12345"

    # Backend configuration is initialized before Terraform variables,
    # so the region is specified directly here.
    region = "us-east-1"

    # Path/name of the Terraform state file inside the S3 bucket
    key = "backend.tfstate"
  }
}

resource "random_id" "random_value" {
  byte_length = 8
}

resource "aws_instance" "mywebserver01" {
  ami           = "ami-0bdc7d025135d7b49"
  instance_type = "t3.micro"

  tags = {
    Name = "mywebserver01-${random_id.random_value.hex}"
  }
}
```

> **Important:** The AMI ID is region-specific. The AMI shown above is intended for `us-east-1`. If you change the AWS region, verify that the AMI exists in that region.

---

# 2. `variable.tf`

The AWS region is defined as a Terraform variable.

```hcl
variable "region" {
  description = "AWS region where resources will be provisioned"

  type    = string
  default = "us-east-1"
}
```

---

# 3. `provider.tf`

The AWS provider uses the region defined in `variable.tf`.

```hcl
provider "aws" {
  region = var.region
}
```

---

# 4. `output.tf`

The output file displays information about the EC2 instance after Terraform creates it.

```hcl
output "ec2_instance_public_ip" {
  value = aws_instance.mywebserver01.public_ip
}

# Fetch EC2 instance Name from the Name tag
output "ec2_instance_name_tags" {
  value = aws_instance.mywebserver01.tags["Name"]
}
```

---

# 🔎 Why We Don't Use `key_name` for Instance Name

The following is **not** the EC2 instance name:

```hcl
aws_instance.mywebserver01.key_name
```

`key_name` represents the **EC2 key pair** associated with the instance.

For example:

```hcl
key_name = "my-ec2-key"
```

This means the SSH key pair is named:

```text
my-ec2-key
```

It does **not** mean that the EC2 instance is named `my-ec2-key`.

The EC2 instance's displayed name comes from the `Name` tag:

```hcl
tags = {
  Name = "mywebserver01-${random_id.random_value.hex}"
}
```

Therefore, the correct Terraform output is:

```hcl
output "ec2_instance_name_tags" {
  value = aws_instance.mywebserver01.tags["Name"]
}
```

---

# 🎲 Why Use `random_id`?

The Random provider generates a random hexadecimal value.

```hcl
resource "random_id" "random_value" {
  byte_length = 8
}
```

The generated value can look similar to:

```text
a83f91c27d5e4b10
```

Terraform then creates the EC2 `Name` tag:

```text
mywebserver01-a83f91c27d5e4b10
```

This gives the instance a unique name.

---

# ☁️ Remote Terraform State with S3

This project uses an **Amazon S3 backend** to store Terraform's state file remotely.

```hcl
backend "s3" {
  bucket = "mybucket-terraform-backend-12345"
  region = "us-east-1"
  key    = "backend.tfstate"
}
```

Instead of keeping:

```text
terraform.tfstate
```

only on the local machine, Terraform stores the state remotely in:

```text
S3 Bucket
    │
    └── backend.tfstate
```

This is useful when working with teams or multiple machines because the Terraform state is maintained centrally.

---

# ⚠️ Important Backend Concept

Terraform initializes the backend before normal Terraform variables are evaluated.

Therefore, this:

```hcl
backend "s3" {
  region = var.region
}
```

is not allowed.

Instead, the backend region is specified directly:

```hcl
backend "s3" {
  region = "us-east-1"
}
```

The provider can still use the variable:

```hcl
provider "aws" {
  region = var.region
}
```

So there are two separate configurations:

```text
Terraform Backend
       │
       └── region = "us-east-1"

AWS Provider
       │
       └── region = var.region
```

---

# 🛠️ Terraform Commands

## 1. Initialize Terraform

```bash
terraform init
```

Terraform will:

* Download the AWS provider
* Download the Random provider
* Initialize the S3 backend
* Configure Terraform to use the remote state

---

## 2. Format Terraform Files

```bash
terraform fmt
```

This formats the Terraform configuration files according to Terraform's standard formatting.

---

## 3. Validate Configuration

```bash
terraform validate
```

Expected result:

```text
Success! The configuration is valid.
```

---

## 4. Create Execution Plan

```bash
terraform plan
```

Terraform will show what resources it plans to create.

You should see resources similar to:

```text
+ random_id.random_value
+ aws_instance.mywebserver01
```

---

## 5. Apply Configuration

```bash
terraform apply
```

Terraform will ask for confirmation.

Enter:

```text
yes
```

Terraform will create:

* Random ID
* EC2 instance

---

# 📤 Terraform Outputs

After successful deployment, run:

```bash
terraform output
```

Example:

```text
ec2_instance_name_tags = "mywebserver01-a83f91c27d5e4b10"
ec2_instance_public_ip = "54.123.45.67"
```

You can also retrieve individual outputs:

```bash
terraform output ec2_instance_public_ip
```

and:

```bash
terraform output ec2_instance_name_tags
```

---

# 🗑️ Destroy Infrastructure

When you no longer need the EC2 instance:

```bash
terraform destroy
```

Enter:

```text
yes
```

Terraform will remove the resources it manages.

---

# 🔐 State File Management

The Terraform state is stored remotely in the configured S3 bucket:

```text
S3 Bucket
└── backend.tfstate
```

The local project should **not** commit a Terraform state file to Git.

Add the following to `.gitignore`:

```gitignore
# Terraform
.terraform/
*.tfstate
*.tfstate.*
.terraform.lock.hcl
crash.log
crash.*.log

# Variable files containing potentially sensitive values
*.tfvars
*.tfvars.json
```

> Note: If you want reproducible provider versions across machines, you may choose to **commit `.terraform.lock.hcl`** rather than ignore it. Terraform normally generates this lock file during `terraform init`.

---

# 🔄 Terraform Workflow

The overall workflow is:

```text
Terraform Configuration
        │
        ▼
terraform init
        │
        ├── AWS Provider
        ├── Random Provider
        └── S3 Backend
        │
        ▼
terraform validate
        │
        ▼
terraform plan
        │
        ▼
terraform apply
        │
        ▼
AWS EC2 Instance
        │
        ▼
Terraform State
        │
        ▼
Amazon S3
```

---

# 🧠 Key Concepts Learned

### Terraform Providers

Providers allow Terraform to communicate with external platforms such as AWS.

```hcl
aws = {
  source  = "hashicorp/aws"
  version = "~> 6.0"
}
```

### Terraform Resources

Resources represent infrastructure that Terraform manages.

```hcl
resource "aws_instance" "mywebserver01" {
  ...
}
```

### Terraform Variables

Variables make configuration reusable.

```hcl
variable "region" {
  type    = string
  default = "us-east-1"
}
```

### Terraform Outputs

Outputs expose useful information after deployment.

```hcl
output "ec2_instance_public_ip" {
  value = aws_instance.mywebserver01.public_ip
}
```

### Remote State

Terraform state can be stored remotely using an S3 backend.

```hcl
backend "s3" {
  bucket = "mybucket-terraform-backend-12345"
  region = "us-east-1"
  key    = "backend.tfstate"
}
```

---

# 🚀 Final Result

This project provisions an AWS EC2 instance using Terraform and stores the Terraform state remotely in Amazon S3.

The EC2 instance receives a dynamically generated name such as:

```text
mywebserver01-a83f91c27d5e4b10
```

Terraform also provides:

```text
Public IP
Instance Name
```

through Terraform outputs.

The project demonstrates the basic Infrastructure as Code workflow:

```text
Write Configuration
        ↓
Initialize
        ↓
Validate
        ↓
Plan
        ↓
Apply
        ↓
Manage Infrastructure
        ↓
Remote State in S3
```
