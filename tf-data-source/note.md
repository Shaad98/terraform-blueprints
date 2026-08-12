# Terraform Data Source – AWS AMI

A hands-on Terraform project demonstrating how to use an **AWS Data Source** to dynamically fetch an existing Amazon Machine Image (AMI) and use it to provision an EC2 instance.

---

## 📌 Project Overview

This project demonstrates:

* Terraform provider configuration
* AWS provider
* Terraform Data Sources
* Fetching an existing AWS AMI
* Using the fetched AMI ID in an EC2 resource
* Terraform outputs
* Dynamic infrastructure configuration

Instead of manually specifying an AMI ID such as:

```hcl
ami = "ami-xxxxxxxxxxxxxxxxx"
```

Terraform can query AWS and retrieve an existing AMI dynamically.

---

## 📁 Project Structure

```text
tf-data-source/
│
├── main.tf
└── README.md
```

---

# 🔹 Terraform Configuration

## Provider Configuration

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```

### Explanation

The `terraform` block specifies the required AWS provider.

```hcl
source = "hashicorp/aws"
```

The provider is maintained by HashiCorp.

```hcl
version = "~> 6.0"
```

This allows compatible AWS provider versions in the `6.x` release series.

The provider configuration specifies that AWS resources should be created in:

```text
us-east-1
```

---

# 🔹 What is a Terraform Data Source?

A **Data Source** allows Terraform to retrieve information about an existing resource or object that Terraform does not need to create.

In simple words:

> A resource creates something, while a data source reads something that already exists.

### Resource

```hcl
resource "aws_instance" "mywebserver01" {
  ...
}
```

Terraform creates an EC2 instance.

### Data Source

```hcl
data "aws_ami" "get_ami" {
  ...
}
```

Terraform searches AWS for an existing AMI and reads its information.

---

# 🔹 Data Source Syntax

The general syntax is:

```hcl
data "<provider>_<resource_type>" "<local_name>" {
  ...
}
```

For this project:

```hcl
data "aws_ami" "get_ami" {
  ...
}
```

There are two important parts:

### Data source type

```hcl
aws_ami
```

This tells Terraform that we want to retrieve information about an AWS AMI.

### Local name

```hcl
get_ami
```

This is the name used to reference the data source elsewhere in the Terraform configuration.

---

# 🔹 Fetching the AMI

Current configuration:

```hcl
data "aws_ami" "get_ami" {
  most_recent = true
  owners      = ["amazon"]
}
```

### `most_recent`

```hcl
most_recent = true
```

This tells Terraform to select the most recent matching AMI.

### `owners`

```hcl
owners = ["amazon"]
```

This restricts the search to AMIs owned by Amazon.

---

# ⚠️ Important: `owners = ["amazon"]` Does Not Mean Amazon Linux

This is an important concept.

The following:

```hcl
owners = ["amazon"]
```

does **not** mean:

> Find the latest Amazon Linux operating system.

It means:

> Search AMIs whose owner is Amazon.

AWS has many different Amazon-owned AMIs.

For example, the query can potentially return images for different AWS services and purposes.

Therefore, using only:

```hcl
most_recent = true
owners      = ["amazon"]
```

may select an AMI that is not the OS image you intended.

---

# 🔹 Using Filters

For a specific operating system, it is better to use filters.

For example, to search for Amazon Linux 2023:

```hcl
data "aws_ami" "get_ami" {
  most_recent = true

  owners = ["amazon"]

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

This makes the AMI selection much more specific.

---

# 🔹 Using the Data Source in an EC2 Resource

The AMI retrieved by the data source can be used by another Terraform resource.

```hcl
resource "aws_instance" "mywebserver01" {
  ami           = data.aws_ami.get_ami.id
  instance_type = "t3.micro"

  tags = {
    Name = "MyWebServer01"
  }
}
```

The important line is:

```hcl
ami = data.aws_ami.get_ami.id
```

Terraform gets the AMI ID from the data source.

The reference follows this pattern:

```text
data.<data_source_type>.<local_name>.<attribute>
```

Therefore:

```hcl
data.aws_ami.get_ami.id
```

means:

```text
data
 ↓
aws_ami
 ↓
get_ami
 ↓
id
```

---

# 🔹 Terraform Data Flow

The overall process is:

```text
Terraform
    │
    ▼
AWS AMI Data Source
    │
    │ Search AWS
    ▼
Matching AMI
    │
    │ Get AMI ID
    ▼
data.aws_ami.get_ami.id
    │
    ▼
aws_instance.mywebserver01
    │
    ▼
EC2 Instance
```

---

# 🔹 Terraform Output

The project can expose information retrieved from the data source using an `output` block.

For example:

```hcl
output "aws_ami_id" {
  value = data.aws_ami.get_ami.id
}
```

This displays the selected AMI ID after Terraform applies the configuration.

Example:

```text
aws_ami_id = "ami-xxxxxxxxxxxxxxxxx"
```

---

# 🔹 Outputting the Complete Data Source

It is also possible to write:

```hcl
output "aws_ami" {
  value = data.aws_ami.get_ami
}
```

This returns the entire data source object.

Because an AMI contains many attributes, Terraform may display information such as:

```text
architecture
arn
block_device_mappings
creation_date
description
ena_support
hypervisor
id
image_id
image_location
image_owner_alias
image_type
name
owner_id
platform_details
root_device_name
root_device_type
state
virtualization_type
```

This is useful for learning and inspecting the data returned by the data source.

However, for a normal project, it is usually cleaner to output only the attributes you need.

---

# 🔹 Useful AMI Outputs

### AMI ID

```hcl
output "aws_ami_id" {
  value = data.aws_ami.get_ami.id
}
```

### AMI Name

```hcl
output "aws_ami_name" {
  value = data.aws_ami.get_ami.name
}
```

### AMI Details

```hcl
output "aws_ami_details" {
  value = {
    id           = data.aws_ami.get_ami.id
    name         = data.aws_ami.get_ami.name
    architecture = data.aws_ami.get_ami.architecture
    owner_id     = data.aws_ami.get_ami.owner_id
  }
}
```

---

# 🔹 Difference Between Resource and Data Source

| Feature               | Resource                       | Data Source                |
| --------------------- | ------------------------------ | -------------------------- |
| Purpose               | Creates/manages infrastructure | Reads existing information |
| Keyword               | `resource`                     | `data`                     |
| Example               | `aws_instance`                 | `aws_ami`                  |
| Creates AWS object    | Yes                            | No                         |
| Reads existing object | Yes, after creation            | Yes                        |
| Example               | Create EC2                     | Find AMI                   |

### Resource example

```hcl
resource "aws_instance" "mywebserver01" {
  ...
}
```

Terraform manages the EC2 instance.

### Data source example

```hcl
data "aws_ami" "get_ami" {
  ...
}
```

Terraform only queries AWS for AMI information.

---

# 🔹 Terraform Commands

## Initialize Terraform

```bash
terraform init
```

Downloads and initializes the required AWS provider.

---

## Format Configuration

```bash
terraform fmt
```

Formats Terraform files according to standard Terraform formatting.

---

## Validate Configuration

```bash
terraform validate
```

Checks whether the Terraform configuration is syntactically and structurally valid.

---

## Create Execution Plan

```bash
terraform plan
```

Terraform queries the AMI data source and shows what infrastructure it plans to create or modify.

Example:

```text
data.aws_ami.get_ami: Reading...
data.aws_ami.get_ami: Read complete

Plan: 1 to add, 0 to change, 0 to destroy.
```

---

## Apply Configuration

```bash
terraform apply
```

Creates the EC2 instance using the AMI selected by the data source.

---

## View Outputs

```bash
terraform output
```

Or retrieve a specific output:

```bash
terraform output aws_ami_id
```

---

## Destroy Infrastructure

```bash
terraform destroy
```

Removes the EC2 instance managed by this Terraform configuration.

The AMI itself is **not deleted**, because it was only read through a data source.

---

# 🔹 Key Concept

The most important concept demonstrated by this project is:

```text
Data Source = Read existing information
Resource    = Create/manage infrastructure
```

In this project:

```text
aws_ami data source
       │
       │ reads
       ▼
Existing AMI in AWS
       │
       │ returns AMI ID
       ▼
aws_instance resource
       │
       │ creates
       ▼
EC2 Instance
```

This approach makes Terraform configurations more dynamic because you don't have to hard-code an AMI ID that may become outdated.

---

# 🎯 What This Project Teaches

After completing this project, you should understand:

* What a Terraform data source is
* Difference between `resource` and `data`
* How Terraform retrieves existing AWS information
* How `aws_ami` works
* How `most_recent` works
* How AMI owners work
* Why AMI filters are important
* How to reference data source attributes
* How to pass a data source value into a resource
* How Terraform outputs work
* How to inspect data returned by a data source

---

## 🚀 Next Step

A good next exercise is to improve the AMI data source by adding filters for:

```text
Amazon Linux 2023
x86_64 architecture
EBS root device
HVM virtualization
```

This will make the EC2 provisioning more predictable and production-friendly.
