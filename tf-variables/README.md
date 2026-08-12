# Terraform Variables – Taking EC2 Instance Type from Terminal

This project demonstrates how to use a **Terraform input variable** without providing a default value.

The EC2 instance type is requested from the user through the terminal when Terraform runs.

The important concept demonstrated here is:

```text
Terraform Variable
       ↓
No default value
       ↓
Terraform asks user for value
       ↓
User enters EC2 instance type
       ↓
Terraform uses the value
```

---

# 📁 Project Structure

```text
tf-variable/
│
├── main.tf
└── README.md
```

---

# Terraform Configuration

The project contains an AWS provider, an EC2 instance, and a variable for the EC2 instance type.

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

resource "aws_instance" "mywebserver01" {
  ami           = "ami-0bdc7d025135d7b49"
  instance_type = var.aws_instance_type

  root_block_device {
    delete_on_termination = true
    volume_size           = 30
    volume_type           = "gp2"
  }

  tags = {
    Name = "MyWebServer01"
  }
}

variable "aws_instance_type" {
  description = "What type of instance you want to create?"
}
```

---

# 1. Terraform Provider

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

This tells Terraform to use the AWS provider from:

```text
hashicorp/aws
```

and use a compatible version from the `6.x` series.

---

# 2. AWS Provider

```hcl
provider "aws" {
  region = "us-east-1"
}
```

This configures Terraform to work with AWS resources in:

```text
us-east-1
```

---

# 3. EC2 Instance

```hcl
resource "aws_instance" "mywebserver01" {
```

This tells Terraform to create an EC2 instance.

The Terraform resource address is:

```text
aws_instance.mywebserver01
```

---

# 4. AMI

```hcl
ami = "ami-0bdc7d025135d7b49"
```

This specifies the AMI that AWS should use to create the EC2 instance.

The AMI must exist in the configured AWS region.

In this project, the configured region is:

```text
us-east-1
```

Therefore, the AMI must be available in `us-east-1`.

---

# 5. EC2 Instance Type Variable

Instead of hard-coding:

```hcl
instance_type = "t3.micro"
```

the configuration uses:

```hcl
instance_type = var.aws_instance_type
```

This means Terraform gets the instance type from the variable:

```hcl
variable "aws_instance_type" {
  description = "What type of instance you want to create?"
}
```

---

# 6. No Default Value

Notice that the variable does not contain:

```hcl
default = "t3.micro"
```

The variable is:

```hcl
variable "aws_instance_type" {
  description = "What type of instance you want to create?"
}
```

Because there is no default value, Terraform does not know which instance type to use automatically.

Therefore, Terraform asks the user.

For example:

```text
var.aws_instance_type
  What type of instance you want to create?

  Enter a value:
```

You can enter:

```text
t3.micro
```

Terraform then uses:

```text
instance_type = "t3.micro"
```

---

# 7. Why Use a Variable?

Without a variable:

```hcl
instance_type = "t3.micro"
```

The instance type is fixed.

If you want a different instance type, you must modify `main.tf`.

With a variable:

```hcl
instance_type = var.aws_instance_type
```

the same Terraform configuration can create different instance types.

For example:

```text
t3.micro
t3.small
t3.medium
t3.large
```

can be entered when Terraform asks for the value.

---

# 8. Root Block Device

The configuration also defines the root EBS volume:

```hcl
root_block_device {
  delete_on_termination = true
  volume_size           = 30
  volume_type           = "gp2"
}
```

### `delete_on_termination`

```hcl
delete_on_termination = true
```

The root EBS volume will be deleted when the EC2 instance is terminated.

### `volume_size`

```hcl
volume_size = 30
```

The root volume size is:

```text
30 GB
```

### `volume_type`

```hcl
volume_type = "gp2"
```

The root volume uses the:

```text
gp2
```

EBS volume type.

---

# 9. EC2 Tags

```hcl
tags = {
  Name = "MyWebServer01"
}
```

This gives the EC2 instance the AWS tag:

```text
Key:   Name
Value: MyWebServer01
```

The tag makes the instance easier to identify in the AWS Console.

---

# 10. Terraform Plan

Run:

```bash
terraform plan
```

Because the variable has no default value, Terraform asks:

```text
var.aws_instance_type
  What type of instance you want to create?

  Enter a value:
```

Enter:

```text
t3.micro
```

Terraform then creates a plan using:

```text
instance_type = "t3.micro"
```

You may see:

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

---

# 11. Important: Plan Does Not Create the EC2

`terraform plan` only creates a proposed execution plan.

It does **not** create the EC2 instance.

```text
terraform plan
      ↓
Read configuration
      ↓
Ask for variable
      ↓
Generate plan
      ↓
NO EC2 CREATED
```

To actually create the EC2:

```bash
terraform apply
```

---

# 12. You Need to Enter the Value Again

This is an important behavior to understand.

Suppose you run:

```bash
terraform plan
```

Terraform asks:

```text
Enter a value:
```

You enter:

```text
t3.micro
```

The plan succeeds.

Later, you run:

```bash
terraform apply
```

Terraform will ask for the variable again:

```text
var.aws_instance_type
  What type of instance you want to create?

  Enter a value:
```

You need to enter:

```text
t3.micro
```

again.

Why?

Because the value was entered interactively for that Terraform command. It was not saved as a permanent variable value.

---

# 13. Plan and Apply Separately

For example:

```bash
terraform plan
```

Enter:

```text
t3.micro
```

Terraform creates the plan.

Then:

```bash
terraform apply
```

Terraform asks again:

```text
Enter a value:
```

Enter:

```text
t3.micro
```

Then Terraform creates the EC2 instance.

---

# 14. What Happens if You Enter an Invalid Instance Type?

Suppose you enter:

```text
t3.this-does-not-exist
```

Terraform can use the value while constructing the configuration/plan because Terraform's variable declaration does not restrict the value to a list of valid EC2 instance types.

The important validation happens when AWS is asked to create the instance.

Therefore, you may get an AWS error during:

```bash
terraform apply
```

For example, AWS may report that the requested instance type is invalid or unsupported.

So:

```text
terraform plan
      ↓
Value accepted by Terraform
      ↓
Plan may succeed
```

but:

```text
terraform apply
      ↓
AWS receives instance type
      ↓
AWS validates it
      ↓
Invalid instance type
      ↓
EC2 creation fails
```

---

# 15. Valid Instance Type

For example:

```text
t3.micro
```

is a valid EC2 instance type in supported AWS regions.

You should still verify that the instance type is available in your selected region.

Your provider uses:

```hcl
region = "us-east-1"
```

so availability should be checked for:

```text
us-east-1
```

---

# 16. How to Avoid Entering the Value Every Time

Instead of entering the value manually every time, you can provide it using a Terraform variable file.

For example, create:

```text
terraform.tfvars
```

with:

```hcl
aws_instance_type = "t3.micro"
```

Then:

```bash
terraform plan
```

and:

```bash
terraform apply
```

will automatically use:

```text
t3.micro
```

without asking for interactive input.

---

# 17. Using `-var`

You can also provide the value directly:

```bash
terraform plan -var="aws_instance_type=t3.micro"
```

And:

```bash
terraform apply -var="aws_instance_type=t3.micro"
```

---

# 18. Variable Flow

The current project follows this flow:

```text
                    Variable Declaration
                           │
                           ▼
              aws_instance_type
                           │
                    No default value
                           │
                           ▼
                  Terraform asks user
                           │
                           ▼
                       t3.micro
                           │
                           ▼
                var.aws_instance_type
                           │
                           ▼
                  EC2 instance_type
```

---

# 19. Important Difference

### Hard-coded value

```hcl
instance_type = "t3.micro"
```

The value is directly written in the configuration.

### Variable

```hcl
instance_type = var.aws_instance_type
```

The value comes from Terraform's variable system.

### Variable without default

```hcl
variable "aws_instance_type" {
  description = "What type of instance you want to create?"
}
```

Terraform requires the value to be supplied from somewhere.

If no value is supplied, Terraform asks interactively.

---

# 20. Commands

Initialize Terraform:

```bash
terraform init
```

Format the configuration:

```bash
terraform fmt
```

Validate the configuration:

```bash
terraform validate
```

Create a plan:

```bash
terraform plan
```

Apply the configuration:

```bash
terraform apply
```

Destroy the created EC2:

```bash
terraform destroy
```

---

# 🎯 Key Learning

The main concept demonstrated by this project is:

```text
variable "aws_instance_type"
```

with **no default value**.

Therefore Terraform needs the user to provide the value.

For example:

```text
terraform plan
      ↓
Enter: t3.micro
      ↓
Plan generated

terraform apply
      ↓
Enter: t3.micro
      ↓
EC2 created
```

If you don't want to enter the value repeatedly, use:

```text
terraform.tfvars
```

or another supported variable mechanism.

The important lesson is:

> **A Terraform variable without a default value must receive its value from another source or Terraform will ask for it interactively.**
