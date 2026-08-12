# Terraform Variables

Terraform variables allow you to pass values into your Terraform configuration without hard-coding those values directly in `.tf` files.

For example, instead of writing:

```hcl
resource "aws_instance" "server" {
  instance_type = "t3.micro"
}
```

we can use a variable:

```hcl
variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

resource "aws_instance" "server" {
  instance_type = var.instance_type
}
```

The value of `instance_type` can then be supplied in different ways.

---

# Ways to Provide Terraform Variables

There are four common ways to provide variable values:

1. Environment Variables
2. `terraform.tfvars`
3. `*.auto.tfvars`
4. `-var` and `-var-file`

---

# 1. Environment Variables

Terraform supports environment variables using the following naming convention:

```text
TF_VAR_<variable_name>
```

For example, if we have:

```hcl
variable "environment" {
  description = "Deployment environment"
  type        = string
}
```

we can provide its value using:

```bash
export TF_VAR_environment="development"
```

Terraform will automatically use:

```text
TF_VAR_environment
```

as the value for:

```text
var.environment
```

---

## Using `.env` File

Terraform does **not automatically load `.env` files**.

For example, create:

```text
.env
```

with:

```text
export TF_VAR_environment="development"
export TF_VAR_instance_type="t3.micro"
```

Then load the variables into the current shell:

```bash
source .env
```

Now Terraform can access those environment variables.

You can verify:

```bash
echo $TF_VAR_environment
```

Output:

```text
development
```

Then:

```bash
terraform plan
```

will use the value.

---

## Using `.bashrc`

You can also define Terraform environment variables in:

```text
~/.bashrc
```

For example:

```bash
export TF_VAR_environment="development"
```

After changing `.bashrc`, reload it:

```bash
source ~/.bashrc
```

---

## Important

Environment variables are **not the highest-priority method** of providing Terraform variables.

They have lower precedence than values provided through `.tfvars`, `*.auto.tfvars`, `-var`, and `-var-file`.

---

# 2. `terraform.tfvars`

`terraform.tfvars` is a standard Terraform variable file.

Terraform automatically loads this file if it exists in the current working directory.

Example:

```text
terraform.tfvars
```

Variable declaration:

```hcl
variable "environment" {
  description = "Deployment environment"
  type        = string
}
```

`terraform.tfvars`:

```hcl
environment = "development"
```

Terraform automatically reads the value:

```text
var.environment = "development"
```

---

## Example

### `variables.tf`

```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}
```

### `terraform.tfvars`

```hcl
instance_type = "t3.micro"
```

### `main.tf`

```hcl
resource "aws_instance" "server" {
  instance_type = var.instance_type
}
```

Terraform will use:

```text
t3.micro
```

---

# 3. `*.auto.tfvars`

Terraform automatically loads variable files ending with:

```text
.auto.tfvars
```

The filename before `.auto.tfvars` can be anything.

For example:

```text
dev.auto.tfvars
```

```text
production.auto.tfvars
```

```text
database.auto.tfvars
```

All of these follow the same syntax:

```hcl
key = value
```

---

## Example

Create:

```text
dev.auto.tfvars
```

with:

```hcl
environment  = "development"
instance_type = "t3.micro"
```

Terraform automatically loads the file.

You don't need to run:

```bash
terraform plan -var-file="dev.auto.tfvars"
```

Simply:

```bash
terraform plan
```

is enough.

---

# Why Use `.auto.tfvars`?

It is useful when you want Terraform to automatically load environment-specific or configuration-specific values.

Example:

```text
project/
│
├── main.tf
├── variables.tf
├── terraform.tfvars
├── dev.auto.tfvars
└── production.auto.tfvars
```

Be careful when using multiple automatically loaded variable files because values can override one another depending on Terraform's variable-loading order.

---

# 4. `-var`

`-var` allows you to provide a variable directly from the terminal.

Example:

```bash
terraform plan -var="environment=production"
```

If the variable is:

```hcl
variable "environment" {
  type = string
}
```

Terraform receives:

```text
environment = production
```

---

## Multiple `-var` Values

You can provide multiple variables:

```bash
terraform plan \
  -var="environment=production" \
  -var="instance_type=t3.micro"
```

For `terraform apply`:

```bash
terraform apply \
  -var="environment=production" \
  -var="instance_type=t3.micro"
```

---

# 5. `-var-file`

`-var-file` allows you to explicitly tell Terraform which variable file to load.

For example:

```text
dev.tfvars
```

contains:

```hcl
environment  = "development"
instance_type = "t3.micro"
```

Run:

```bash
terraform plan -var-file="dev.tfvars"
```

Terraform will load the values from:

```text
dev.tfvars
```

---

## Directory Example

```text
terraform-project/
│
├── main.tf
├── variables.tf
├── dev.tfvars
└── prod.tfvars
```

### `dev.tfvars`

```hcl
environment   = "development"
instance_type = "t3.micro"
```

### `prod.tfvars`

```hcl
environment   = "production"
instance_type = "t3.medium"
```

For development:

```bash
terraform plan -var-file="dev.tfvars"
```

For production:

```bash
terraform plan -var-file="prod.tfvars"
```

This allows you to use the same Terraform configuration for different environments.

---

# Variable Precedence

When the same variable receives values from multiple sources, Terraform needs to decide which value should be used.

For the methods discussed here, think of the priority from **lower to higher** as:

```text
Environment Variables
        ↓
terraform.tfvars
        ↓
*.auto.tfvars
        ↓
-var / -var-file
```

The higher-priority value overrides the lower-priority value.

---

# Example of Precedence

Suppose we have:

```hcl
variable "environment" {
  type = string
}
```

### Environment variable

```bash
export TF_VAR_environment="development"
```

### `terraform.tfvars`

```hcl
environment = "testing"
```

### `dev.auto.tfvars`

```hcl
environment = "staging"
```

### Command line

```bash
terraform plan -var="environment=production"
```

The final value will be:

```text
production
```

because `-var` has higher precedence.

---

# What If No Value Is Provided?

Suppose you define:

```hcl
variable "environment" {
  description = "Deployment environment"
  type        = string
}
```

and you don't provide:

* a default value
* an environment variable
* a `.tfvars` value
* an `auto.tfvars` value
* a `-var` value

Terraform will ask you interactively.

For example:

```text
var.environment
  Deployment environment

  Enter a value:
```

You can enter:

```text
development
```

Terraform will then use:

```text
var.environment = "development"
```

---

# Using a Default Value

You can avoid the interactive prompt by defining a default:

```hcl
variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "development"
}
```

Now, if no other value is supplied:

```text
var.environment = "development"
```

will be used.

---

# Complete Example

## `variables.tf`

```hcl
variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}
```

## `main.tf`

```hcl
resource "aws_instance" "server" {
  ami           = "ami-xxxxxxxxxxxxxxxxx"
  instance_type = var.instance_type

  tags = {
    Name        = "my-server"
    Environment = var.environment
  }
}
```

## `terraform.tfvars`

```hcl
environment   = "development"
instance_type = "t3.micro"
```

Run:

```bash
terraform plan
```

Terraform automatically loads:

```text
terraform.tfvars
```

---

# Using a Different Environment

Create:

```text
production.tfvars
```

```hcl
environment   = "production"
instance_type = "t3.medium"
```

Run:

```bash
terraform plan -var-file="production.tfvars"
```

Now the same Terraform code can be used for production without changing `main.tf`.

---

# Important Difference: `.tfvars` vs `.auto.tfvars`

### `terraform.tfvars`

Automatically loaded because it has Terraform's standard filename:

```text
terraform.tfvars
```

### `dev.auto.tfvars`

Automatically loaded because it ends with:

```text
.auto.tfvars
```

### `dev.tfvars`

**Not automatically loaded.**

You must explicitly specify it:

```bash
terraform plan -var-file="dev.tfvars"
```

This distinction is important.

---

# Summary

| Method               | Automatically Loaded? | Example                                 |
| -------------------- | --------------------- | --------------------------------------- |
| Environment variable | Yes, if exported      | `TF_VAR_environment=dev`                |
| `terraform.tfvars`   | Yes                   | `environment = "dev"`                   |
| `*.auto.tfvars`      | Yes                   | `dev.auto.tfvars`                       |
| `*.tfvars`           | No                    | `terraform plan -var-file="dev.tfvars"` |
| `-var`               | Explicitly provided   | `-var="environment=dev"`                |
| `-var-file`          | Explicitly provided   | `-var-file="dev.tfvars"`                |

---

# Key Points to Remember

1. Terraform variables are declared using the `variable` block.
2. Environment variables use the `TF_VAR_` prefix.
3. `.env` files are **not automatically read by Terraform**.
4. `terraform.tfvars` is automatically loaded.
5. Any file ending in `.auto.tfvars` is automatically loaded.
6. Normal `.tfvars` files must be supplied using `-var-file`.
7. `-var` allows values to be supplied directly from the command line.
8. `-var-file` allows an entire variable file to be supplied from the command line.
9. If a required variable has no value and no default, Terraform prompts for it.
10. Higher-precedence values override lower-precedence values.
11. Never commit sensitive values such as passwords, API keys, or secrets to Git.
12. For sensitive variables, consider using environment variables or a dedicated secret-management solution.

---

# Quick Reference

```bash
# Environment variable
export TF_VAR_environment="development"

# Load .env
source .env

# Automatically loaded
terraform.tfvars

# Automatically loaded
dev.auto.tfvars

# Explicit variable
terraform plan -var="environment=production"

# Explicit variable file
terraform plan -var-file="production.tfvars"

# Apply with variable file
terraform apply -var-file="production.tfvars"
```

The central idea is:

```text
Variable Declaration
        ↓
variable "environment"
        ↓
      Value
        ↓
 ┌──────┴────────────────────────┐
 │                               │
TF_VAR_                    .tfvars files
 │                               │
 └──────────────┬────────────────┘
                ↓
          Terraform
                ↓
          var.environment
```
