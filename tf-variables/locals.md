# Terraform Locals

Terraform **locals** allow you to assign a name to an expression or value so that it can be reused throughout a Terraform configuration.

Locals are useful for values that are **internal to the Terraform configuration**, especially values that are calculated from variables or reused in multiple resources.

---

## Basic Local

```hcl
locals {
  region = "us-east-1"
}
```

The local can then be referenced using:

```hcl
local.region
```

For example:

```hcl
provider "aws" {
  region = local.region
}
```

Here:

```text
locals {
  region = "us-east-1"
}
       ↓
local.region
       ↓
provider "aws"
```

The value `"us-east-1"` is defined inside the Terraform configuration.

---

# Variables vs Locals

The easiest way to understand the difference is:

```text
Variable = INPUT to Terraform
Local    = INTERNAL value used by Terraform
```

## Variable

A variable is designed to receive input from outside the Terraform configuration.

```hcl
variable "aws_instance_type" {
  type = string
}
```

Its value can be supplied using different methods:

```bash
terraform apply -var="aws_instance_type=t3.micro"
```

or:

```hcl
# terraform.tfvars

aws_instance_type = "t3.micro"
```

or:

```hcl
# dev.auto.tfvars

aws_instance_type = "t3.small"
```

or:

```bash
terraform apply -var-file="production.tfvars"
```

Therefore, variables can be **overridden by external input**.

---

## Local

A local is defined inside the Terraform configuration:

```hcl
locals {
  region = "us-east-1"
}
```

It is referenced using:

```hcl
local.region
```

A local cannot be overridden using:

```bash
terraform apply -var="region=ap-south-1"
```

and it cannot be overridden through:

```hcl
terraform.tfvars
```

because `region` here is a local, not an input variable.

---

# Simple Difference

| Feature                           | Variable     | Local                       |
| --------------------------------- | ------------ | --------------------------- |
| Purpose                           | Accept input | Store/reuse internal values |
| Defined with                      | `variable`   | `locals`                    |
| Reference                         | `var.name`   | `local.name`                |
| `-var` can override it            | Yes          | No                          |
| `terraform.tfvars` can provide it | Yes          | No                          |
| `*.auto.tfvars` can provide it    | Yes          | No                          |
| `-var-file` can provide it        | Yes          | No                          |
| Can depend on variables           | Yes          | Yes                         |
| Useful for calculated values      | Sometimes    | Very useful                 |
| Usually externally configurable   | Yes          | No                          |

---

# Locals Can Depend on Variables

Locals become especially useful when a value needs to be calculated or reused.

```hcl
variable "environment" {
  type = string
}

locals {
  application_name = "my-app-${var.environment}"
}
```

If:

```text
environment = "dev"
```

then:

```text
local.application_name
        ↓
my-app-dev
```

If:

```text
environment = "prod"
```

then:

```text
local.application_name
        ↓
my-app-prod
```

The local itself was not overridden. Its value changed because the variable it depends on changed.

---

# Multiple Locals

A `locals` block can contain multiple values:

```hcl
locals {
  region      = "us-east-1"
  environment = "dev"
  project     = "terraform-lab"
}
```

They are referenced independently:

```hcl
local.region
local.environment
local.project
```

---

# Locals for Reusable Tags

A common real-world use case is storing common tags:

```hcl
locals {
  common_tags = {
    Project     = "Terraform"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```

Then:

```hcl
tags = local.common_tags
```

This avoids repeating the same tags in multiple resources.

---

# Example from This Terraform Project

The configuration uses a local for the AWS region:

```hcl
locals {
  region = "us-east-1"
}
```

The provider uses that local:

```hcl
provider "aws" {
  region = local.region
}
```

Meanwhile, the EC2 configuration uses input variables:

```hcl
resource "aws_instance" "mywebserver01" {
  ami           = "ami-0bdc7d025135d7b49"
  instance_type = var.aws_instance_type

  root_block_device {
    delete_on_termination = true
    volume_size            = var.ec2_config.v_size
    volume_type            = var.ec2_config.v_type
  }

  tags = merge(
    var.additional_tags,
    {
      Name = "MyWebServer01"
    }
  )
}
```

Here the difference is:

```text
local.region
    ↓
Internal Terraform value
    ↓
AWS provider region
```

while:

```text
var.aws_instance_type
var.ec2_config
var.additional_tags
        ↓
External Terraform inputs
        ↓
EC2 resource
```

---

# Important Syntax

### Declare a local

```hcl
locals {
  name = "value"
}
```

### Use a local

```hcl
local.name
```

### Declare a variable

```hcl
variable "name" {
  type = string
}
```

### Use a variable

```hcl
var.name
```

---

# Mental Model

Remember this:

```text
                Terraform

External Input
     │
     ▼
┌─────────────┐
│  variable   │
│  var.name   │
└─────────────┘
     │
     ▼
┌─────────────┐
│    local    │
│ local.name  │
└─────────────┘
     │
     ▼
┌─────────────┐
│  resource   │
└─────────────┘
```

A variable is generally **input**, while a local is generally **internal reusable or calculated data**.

---

# Key Takeaway

```text
variable → can receive external input and be overridden

local    → defined inside Terraform and cannot be externally overridden
```

Locals are especially useful when you want to avoid repeating expressions, create calculated values, or keep resource configurations clean and readable.
