# Terraform Variables

This project demonstrates how to use **Terraform input variables** to make infrastructure configurations flexible and reusable.

Instead of hard-coding values directly inside resources, Terraform variables allow us to provide values from different sources and use those values inside our infrastructure configuration.

This project demonstrates:

* Terraform input variables
* Different Terraform variable types
* Required variables
* Default values
* Variable validation
* Object variables
* Map variables
* Using variables inside resources
* `merge()` function with variables
* Providing variables from the terminal
* `terraform.tfvars`
* `.auto.tfvars`
* Environment variables
* `-var`
* `-var-file`

---

# 📁 Project Structure

```text
tf-variable/
│
├── main.tf
├── variables.tf
└── README.md
```

---

# 1. What is a Terraform Variable?

A Terraform variable is an input value that allows us to make our Terraform configuration configurable.

Instead of hard-coding:

```hcl
instance_type = "t3.micro"
```

we can declare a variable:

```hcl
variable "aws_instance_type" {
  type = string
}
```

and use it inside the resource:

```hcl
instance_type = var.aws_instance_type
```

The flow is:

```text
Variable Declaration
        ↓
Variable Value
        ↓
var.variable_name
        ↓
Terraform Resource
        ↓
AWS Infrastructure
```

---

# 2. Variable Declaration

Terraform variables are declared using the `variable` block.

Example:

```hcl
variable "aws_instance_type" {
  description = "What type of instance you want to create?"
  type        = string
}
```

Here:

```text
aws_instance_type
```

is the variable name.

The variable can be accessed inside Terraform using:

```hcl
var.aws_instance_type
```

---

# 3. Variable Description

The `description` argument explains what the variable represents.

```hcl
variable "aws_instance_type" {
  description = "What type of instance you want to create?"
}
```

When Terraform asks for the value interactively, this description can be displayed to the user.

For example:

```text
var.aws_instance_type
  What type of instance you want to create?

  Enter a value:
```

---

# 4. Terraform Variable Types

Terraform supports several important variable types.

The commonly used types are:

```text
string
number
bool
list
set
map
object
tuple
```

---

# 5. String

A `string` contains text.

Example:

```hcl
variable "aws_instance_type" {
  type = string
}
```

Value:

```hcl
aws_instance_type = "t3.micro"
```

Another example:

```hcl
variable "environment" {
  type = string
}
```

Value:

```hcl
environment = "production"
```

---

# 6. Number

A `number` represents a numeric value.

Example:

```hcl
variable "volume_size" {
  type = number
}
```

Value:

```hcl
volume_size = 30
```

It can be used in the resource:

```hcl
root_block_device {
  volume_size = var.volume_size
}
```

---

# 7. Boolean

A `bool` contains either:

```text
true
```

or:

```text
false
```

Example:

```hcl
variable "delete_on_termination" {
  type = bool
}
```

Value:

```hcl
delete_on_termination = true
```

Usage:

```hcl
root_block_device {
  delete_on_termination = var.delete_on_termination
}
```

---

# 8. List

A `list` contains multiple values in a specific order.

Example:

```hcl
variable "availability_zones" {
  type = list(string)
}
```

Value:

```hcl
availability_zones = [
  "us-east-1a",
  "us-east-1b",
  "us-east-1c"
]
```

Access an individual element using its index:

```hcl
var.availability_zones[0]
```

This returns:

```text
us-east-1a
```

Terraform list indexes start from:

```text
0
```

---

# 9. Set

A `set` contains multiple unique values.

Example:

```hcl
variable "security_groups" {
  type = set(string)
}
```

Value:

```hcl
security_groups = [
  "web-sg",
  "app-sg",
  "db-sg"
]
```

Unlike a list, a set is intended for unique values and does not preserve a meaningful ordering.

---

# 10. Map

A `map` contains key-value pairs.

For example:

```hcl
variable "additional_tags" {
  type = map(string)
}
```

Value:

```hcl
additional_tags = {
  env  = "prod"
  team = "backend"
}
```

The type:

```hcl
map(string)
```

means:

```text
Key   → string
Value → string
```

For example:

```text
env  → prod
team → backend
```

Maps are very useful for AWS tags.

---

# 11. Object

An `object` allows us to define multiple attributes with specific types.

Our project uses:

```hcl
variable "ec2_config" {
  type = object({
    v_size = number
    v_type = string
  })
}
```

This means `ec2_config` must contain:

```text
v_size → number
v_type → string
```

Example:

```hcl
ec2_config = {
  v_size = 30
  v_type = "gp2"
}
```

This is useful when multiple related configuration values belong together.

---

# 12. Accessing Object Values

Because `ec2_config` is an object, we can access its attributes using dot notation.

For volume size:

```hcl
var.ec2_config.v_size
```

For volume type:

```hcl
var.ec2_config.v_type
```

Our EC2 resource uses them like this:

```hcl
root_block_device {
  volume_size = var.ec2_config.v_size
  volume_type = var.ec2_config.v_type
}
```

The flow is:

```text
var.ec2_config
       ↓
 ┌─────┴─────┐
 ↓           ↓
v_size      v_type
 ↓           ↓
30          gp2
 ↓           ↓
Volume Size Volume Type
```

---

# 13. Tuple

A tuple is a collection where each position can have a specific type.

Example:

```hcl
variable "server_config" {
  type = tuple([
    string,
    number,
    bool
  ])
}
```

Value:

```hcl
server_config = [
  "web-server",
  30,
  true
]
```

The types must follow the defined order:

```text
Index 0 → string
Index 1 → number
Index 2 → bool
```

Access values using indexes:

```hcl
var.server_config[0]
```

```hcl
var.server_config[1]
```

```hcl
var.server_config[2]
```

Tuples are less commonly used than objects when describing infrastructure configuration because objects are usually easier to understand.

---

# 14. Default Values

A variable can have a default value.

Example:

```hcl
variable "ec2_config" {
  type = object({
    v_size = number
    v_type = string
  })

  default = {
    v_size = 30
    v_type = "gp2"
  }
}
```

If the user doesn't provide `ec2_config`, Terraform uses:

```text
v_size = 30
v_type = gp2
```

A default value makes a variable optional.

---

# 15. Required Variable

If a variable does not have a default value, Terraform requires a value from another source.

Example:

```hcl
variable "aws_instance_type" {
  description = "What type of instance you want to create?"
  type        = string
}
```

There is no:

```hcl
default = ...
```

Therefore Terraform needs the value.

If no value is supplied, Terraform asks:

```text
var.aws_instance_type
  What type of instance you want to create?

  Enter a value:
```

For example:

```text
t3.micro
```

---

# 16. Variable Validation

Terraform allows us to validate variable values before using them.

Our project contains:

```hcl
variable "aws_instance_type" {
  description = "What type of instance you want to create?"
  type        = string

  validation {
    condition = (
      var.aws_instance_type == "t2.micro" ||
      var.aws_instance_type == "t3.micro"
    )

    error_message = "Only t2.micro and t3.micro are allowed."
  }
}
```

This means only these values are accepted:

```text
t2.micro
t3.micro
```

---

# 17. What Happens With an Invalid Value?

Suppose we run:

```bash
terraform plan
```

and enter:

```text
t3.large
```

Terraform checks the validation condition.

The condition is:

```hcl
var.aws_instance_type == "t2.micro" ||
var.aws_instance_type == "t3.micro"
```

`t3.large` does not satisfy the condition.

Terraform stops and displays the custom error:

```text
Only t2.micro and t3.micro are allowed.
```

Therefore, in this project, invalid values are rejected during Terraform's variable validation.

The validation happens before Terraform proceeds with the infrastructure operation.

---

# 18. Using Variables Inside Resources

Variables become useful when we use them inside resources.

Example:

```hcl
resource "aws_instance" "mywebserver01" {
  ami           = "ami-0bdc7d025135d7b49"
  instance_type = var.aws_instance_type
}
```

Here:

```text
var.aws_instance_type
```

provides the value for:

```text
aws_instance.instance_type
```

If the user enters:

```text
t3.micro
```

Terraform effectively uses:

```hcl
instance_type = "t3.micro"
```

---

# 19. Using an Object Variable Inside a Resource

Our project uses:

```hcl
variable "ec2_config" {
  type = object({
    v_size = number
    v_type = string
  })

  default = {
    v_size = 30
    v_type = "gp2"
  }
}
```

The EC2 resource uses it:

```hcl
root_block_device {
  delete_on_termination = true
  volume_size           = var.ec2_config.v_size
  volume_type           = var.ec2_config.v_type
}
```

Terraform gets:

```text
var.ec2_config.v_size
        ↓
30
```

and:

```text
var.ec2_config.v_type
        ↓
gp2
```

So the resulting configuration is effectively:

```hcl
root_block_device {
  delete_on_termination = true
  volume_size           = 30
  volume_type           = "gp2"
}
```

---

# 20. Using Map Variables for Tags

Our project contains:

```hcl
variable "additional_tags" {
  type = map(string)

  default = {
    env = "prod"
  }
}
```

This allows additional tags to be supplied as a map.

For example:

```hcl
additional_tags = {
  env  = "prod"
  team = "backend"
}
```

---

# 21. Using `merge()` With Tags

Our EC2 resource uses:

```hcl
tags = merge(
  var.additional_tags,
  {
    Name = "MyWebServer01"
  }
)
```

`merge()` combines multiple maps into one map.

For example:

```text
additional_tags:

env = "prod"
team = "backend"
```

and:

```text
Name = "MyWebServer01"
```

become:

```text
env  = "prod"
team = "backend"
Name = "MyWebServer01"
```

The final EC2 tags are therefore:

```hcl
tags = {
  env  = "prod"
  team = "backend"
  Name = "MyWebServer01"
}
```

---

# 22. Important `merge()` Rule

If the same key exists in both maps, the value from the later map takes precedence.

Example:

```hcl
merge(
  {
    Name = "OldName"
  },
  {
    Name = "NewName"
  }
)
```

Result:

```text
Name = "NewName"
```

In our configuration:

```hcl
merge(
  var.additional_tags,
  {
    Name = "MyWebServer01"
  }
)
```

the `Name` value defined in the second map takes precedence.

---

# 23. Complete Current `variables.tf`

```hcl
# EC2 instance type
variable "aws_instance_type" {
  description = "What type of instance you want to create?"
  type        = string

  validation {
    condition = (
      var.aws_instance_type == "t2.micro" ||
      var.aws_instance_type == "t3.micro"
    )

    error_message = "Only t2.micro and t3.micro are allowed."
  }
}

# EC2 storage configuration
variable "ec2_config" {
  type = object({
    v_size = number
    v_type = string
  })

  default = {
    v_size = 30
    v_type = "gp2"
  }
}

# Additional EC2 tags
variable "additional_tags" {
  type = map(string)

  default = {
    env = "prod"
  }
}
```

---

# 24. Complete Current `main.tf`

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

  # AMI used to create the EC2 instance.
  ami = "ami-0bdc7d025135d7b49"

  # Instance type comes from the Terraform variable.
  instance_type = var.aws_instance_type

  # Root EBS volume configuration.
  root_block_device {
    delete_on_termination = true
    volume_size           = var.ec2_config.v_size
    volume_type           = var.ec2_config.v_type
  }

  # Combine user-provided tags with the Name tag.
  tags = merge(
    var.additional_tags,
    {
      Name = "MyWebServer01"
    }
  )
}
```

---

# 25. Ways to Provide Variable Values

Terraform variables can receive values from multiple sources.

## Environment Variable

Terraform environment variables use:

```text
TF_VAR_<variable_name>
```

Example:

```bash
export TF_VAR_aws_instance_type="t3.micro"
```

Terraform reads it as:

```hcl
var.aws_instance_type
```

---

## `.env` File

Terraform does **not automatically load `.env` files**.

Example `.env`:

```text
export TF_VAR_aws_instance_type="t3.micro"
```

Load it:

```bash
source .env
```

Then Terraform can access the exported variable.

---

# 26. `terraform.tfvars`

Terraform automatically loads:

```text
terraform.tfvars
```

Example:

```hcl
aws_instance_type = "t3.micro"

ec2_config = {
  v_size = 30
  v_type = "gp2"
}

additional_tags = {
  env  = "prod"
  team = "backend"
}
```

Then simply run:

```bash
terraform plan
```

---

# 27. `.auto.tfvars`

Terraform automatically loads files ending in:

```text
.auto.tfvars
```

For example:

```text
dev.auto.tfvars
```

```hcl
aws_instance_type = "t3.micro"
```

Then:

```bash
terraform plan
```

automatically loads the file.

---

# 28. Normal `.tfvars` Files

A file such as:

```text
production.tfvars
```

is **not automatically loaded**.

You must explicitly specify it:

```bash
terraform plan -var-file="production.tfvars"
```

For example:

```hcl
aws_instance_type = "t3.micro"

ec2_config = {
  v_size = 30
  v_type = "gp2"
}
```

---

# 29. `-var`

A variable can be supplied directly from the terminal.

Example:

```bash
terraform plan -var="aws_instance_type=t3.micro"
```

For multiple variables:

```bash
terraform plan \
  -var="aws_instance_type=t3.micro" \
  -var='ec2_config={v_size=30,v_type="gp2"}'
```

---

# 30. `-var-file`

A complete variable file can be provided using:

```bash
terraform plan -var-file="production.tfvars"
```

and:

```bash
terraform apply -var-file="production.tfvars"
```

This is useful when different environments need different values.

For example:

```text
dev.tfvars
prod.tfvars
```

---

# 31. Variable Precedence

When the same variable is provided from multiple sources, Terraform uses variable precedence to determine which value wins.

For the methods covered in this project, the general order is:

```text
Lower Priority
      ↓
Environment Variables
      ↓
terraform.tfvars
      ↓
*.auto.tfvars
      ↓
-var / -var-file
      ↓
Higher Priority
```

Therefore, a higher-priority value can override a lower-priority value.

---

# 32. Plan and Apply With Interactive Variables

If a variable has no default and no value is supplied from another source:

```bash
terraform plan
```

Terraform asks:

```text
var.aws_instance_type
  What type of instance you want to create?

  Enter a value:
```

Enter:

```text
t3.micro
```

Terraform creates the plan.

If you later run:

```bash
terraform apply
```

as a separate command, Terraform may ask for the variable again because the interactive value was not saved as a permanent configuration value.

Therefore, you may need to enter:

```text
t3.micro
```

again.

---

# 33. Why Use `terraform.tfvars`?

Instead of entering:

```text
t3.micro
```

every time, create:

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

can automatically use the value.

---

# 34. Complete Variable Flow

The current project demonstrates this flow:

```text
                    Variable Declaration
                           │
             ┌─────────────┼──────────────┐
             │             │              │
          string         object          map
             │             │              │
             ▼             ▼              ▼
    aws_instance_type  ec2_config   additional_tags
             │             │              │
             │       ┌─────┴─────┐         │
             │       │           │         │
             │     v_size      v_type      │
             │       │           │         │
             ▼       ▼           ▼         ▼
        EC2 Type   30 GB        gp2      EC2 Tags
             │       │           │         │
             └───────┴───────────┴─────────┘
                         │
                         ▼
                   EC2 Resource
```

---

# 35. Why Variables Are Useful

Without variables, infrastructure becomes tightly coupled to hard-coded values.

For example:

```hcl
instance_type = "t3.micro"
volume_size   = 30
volume_type   = "gp2"
```

If you want another environment, you have to modify the Terraform configuration.

With variables:

```hcl
instance_type = var.aws_instance_type
volume_size   = var.ec2_config.v_size
volume_type   = var.ec2_config.v_type
```

the same Terraform configuration can be reused with different values.

For example:

```text
Development
    ↓
t3.micro
30 GB
gp2

Production
    ↓
t3.micro
50 GB
gp3
```

The Terraform resource itself does not need to change.

---

# 36. Commands

Initialize Terraform:

```bash
terraform init
```

Format Terraform files:

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

Destroy resources:

```bash
terraform destroy
```

Use a variable file:

```bash
terraform plan -var-file="production.tfvars"
```

Provide a variable directly:

```bash
terraform plan -var="aws_instance_type=t3.micro"
```

---

# 37. Key Learning

This project demonstrates that Terraform variables are not limited to simple strings.

They can represent:

```text
string
number
bool
list
set
map
object
tuple
```

Variables can also have:

```text
Description
   ↓
Type
   ↓
Default Value
   ↓
Validation
```

The value can come from:

```text
Environment Variables
        ↓
terraform.tfvars
        ↓
*.auto.tfvars
        ↓
-var / -var-file
        ↓
Interactive Input
```

The variable is then consumed inside the Terraform resource using:

```hcl
var.variable_name
```

For nested objects:

```hcl
var.ec2_config.v_size
```

For maps:

```hcl
var.additional_tags
```

And functions such as `merge()` can be used to combine variable values with resource-specific configuration.

> **The main purpose of Terraform variables is to separate infrastructure configuration from infrastructure code, making the same Terraform configuration reusable with different values.**
