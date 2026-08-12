# Terraform Variable CLI Overrides

This exercise demonstrates different ways to override Terraform input variables, especially:

* `-var`
* `*.auto.tfvars`
* `-var-file`
* Variable precedence
* Using environment-specific variable files

---

# 📁 Project Structure

```text
tf-variable/
│
├── main.tf
├── variables.tf
├── terraform.tfvars
├── prod.auto.tfvars
├── dev.auto.tfvars
└── variable-cli-overrides.md
```

---

# 1. Current `ec2_config` Variable

The project contains an `ec2_config` variable:

```hcl
variable "ec2_config" {
  type = object({
    v_size = number
    v_type = string
  })

  default = {
    v_size = 8
    v_type = "gp3"
  }
}
```

The default configuration is:

```text
Volume Size → 8 GB
Volume Type → gp3
```

The variable is used in the EC2 resource:

```hcl
root_block_device {
  delete_on_termination = true
  volume_size           = var.ec2_config.v_size
  volume_type           = var.ec2_config.v_type
}
```

---

# 2. Override Using `-var`

Terraform allows us to provide a variable value directly from the command line using:

```text
-var
```

The current default value is:

```hcl
ec2_config = {
  v_size = 8
  v_type = "gp3"
}
```

We can temporarily override it with:

```bash
terraform plan -var='ec2_config={v_size=16,v_type="gp3"}'
```

Now Terraform uses:

```text
Volume Size → 16 GB
Volume Type → gp3
```

instead of:

```text
Volume Size → 8 GB
Volume Type → gp3
```

---

# 3. Using `-var` With `terraform apply`

The same value can be provided during `apply`:

```bash
terraform apply -var='ec2_config={v_size=16,v_type="gp3"}'
```

Terraform will use:

```text
v_size = 16
v_type = gp3
```

when creating or modifying the infrastructure.

---

# 4. Important: `-var` Is Temporary

When using:

```bash
terraform plan -var='ec2_config={v_size=16,v_type="gp3"}'
```

the value is supplied only for that command.

It does not modify:

```text
main.tf
variables.tf
terraform.tfvars
```

If you separately run:

```bash
terraform apply
```

you must provide the value again if Terraform does not have another value available.

For example:

```bash
terraform apply -var='ec2_config={v_size=16,v_type="gp3"}'
```

This ensures that plan and apply use the same variable value.

---

# 5. Create `dev.auto.tfvars`

Now create:

```text
dev.auto.tfvars
```

with:

```hcl
ec2_config = {
  v_size = 16
  v_type = "gp3"
}
```

This file overrides the default `ec2_config`.

The default is:

```text
8 GB gp3
```

The development override is:

```text
16 GB gp3
```

---

# 6. Using `dev.auto.tfvars` With `terraform plan`

Because the file ends with:

```text
.auto.tfvars
```

Terraform automatically loads it.

Therefore, simply run:

```bash
terraform plan
```

Terraform automatically reads:

```text
dev.auto.tfvars
```

and uses:

```text
16 GB gp3
```

for `ec2_config`.

You do **not** need to write:

```bash
terraform plan -var-file="dev.auto.tfvars"
```

because `.auto.tfvars` files are automatically loaded.

---

# 7. Using `dev.auto.tfvars` With `terraform apply`

The same applies to:

```bash
terraform apply
```

Terraform automatically loads:

```text
dev.auto.tfvars
```

and uses:

```hcl
ec2_config = {
  v_size = 16
  v_type = "gp3"
}
```

Therefore:

```bash
terraform apply
```

is enough.

---

# 8. Multiple `.auto.tfvars` Files

Suppose the directory contains:

```text
dev.auto.tfvars
prod.auto.tfvars
qa.auto.tfvars
```

Terraform automatically loads **all matching `.auto.tfvars` files**.

For example:

```text
terraform plan
       ↓
Terraform finds
       ↓
dev.auto.tfvars
prod.auto.tfvars
qa.auto.tfvars
       ↓
All are automatically loaded
```

You do not specify which `.auto.tfvars` file Terraform should load.

---

# 9. Be Careful With Multiple `.auto.tfvars` Files

Suppose:

### `dev.auto.tfvars`

```hcl
ec2_config = {
  v_size = 8
  v_type = "gp3"
}
```

### `prod.auto.tfvars`

```hcl
ec2_config = {
  v_size = 16
  v_type = "gp3"
}
```

Both files are automatically loaded.

If the same variable is defined in multiple variable files, one value can override another according to Terraform's variable-file loading rules.

Therefore, it is usually **not a good idea to keep separate `dev.auto.tfvars` and `prod.auto.tfvars` files in the same working directory when they define the same variables**.

Instead, use environment-specific files with `-var-file`.

---

# 10. Using `-var-file`

`-var-file` allows us to explicitly tell Terraform which variable file to use.

For example:

```text
dev.tfvars
prod.tfvars
```

### `dev.tfvars`

```hcl
ec2_config = {
  v_size = 8
  v_type = "gp3"
}
```

### `prod.tfvars`

```hcl
ec2_config = {
  v_size = 16
  v_type = "gp3"
}
```

Now we can explicitly select the environment.

---

# 11. Use the Development Configuration

Run:

```bash
terraform plan -var-file="dev.tfvars"
```

Terraform uses the values from:

```text
dev.tfvars
```

To apply:

```bash
terraform apply -var-file="dev.tfvars"
```

---

# 12. Use the Production Configuration

For production:

```bash
terraform plan -var-file="prod.tfvars"
```

and:

```bash
terraform apply -var-file="prod.tfvars"
```

This allows us to explicitly select the environment.

---

# 13. `.auto.tfvars` vs `-var-file`

### `.auto.tfvars`

Example:

```text
dev.auto.tfvars
```

Terraform automatically loads it:

```bash
terraform plan
```

No file needs to be specified.

### `-var-file`

Example:

```text
dev.tfvars
prod.tfvars
```

You explicitly select the file:

```bash
terraform plan -var-file="dev.tfvars"
```

or:

```bash
terraform plan -var-file="prod.tfvars"
```

---

# 14. When Should You Use Each?

### Use `.auto.tfvars` when:

You want Terraform to automatically load the variable file.

Example:

```text
dev.auto.tfvars
```

Then:

```bash
terraform plan
```

automatically loads it.

### Use `-var-file` when:

You have different environment configurations and want to explicitly choose one.

Example:

```text
dev.tfvars
prod.tfvars
```

Then:

```bash
terraform plan -var-file="dev.tfvars"
```

or:

```bash
terraform plan -var-file="prod.tfvars"
```

This is generally clearer for environment-specific configurations.

---

# 15. Variable Precedence

Terraform has several ways to provide variable values.

A simplified precedence order is:

```text
Variable default
       ↓
Environment variable
       ↓
terraform.tfvars
       ↓
*.auto.tfvars
       ↓
-var / -var-file
       ↓
Higher priority
```

Therefore, a higher-priority value can override a lower-priority value.

For example:

```text
Variable default
8 GB
   ↓
Environment variable
10 GB
   ↓
terraform.tfvars
12 GB
   ↓
dev.auto.tfvars
16 GB
   ↓
-var
20 GB
```

The final value used by Terraform is:

```text
20 GB
```

because the command-line `-var` value has higher precedence.

---

# 16. Example Using `terraform.tfvars`

Suppose:

```hcl
# terraform.tfvars

ec2_config = {
  v_size = 8
  v_type = "gp3"
}
```

Then:

```bash
terraform plan
```

uses:

```text
8 GB gp3
```

If we run:

```bash
terraform plan -var='ec2_config={v_size=16,v_type="gp3"}'
```

the command-line value overrides the value from `terraform.tfvars`.

The result is:

```text
16 GB gp3
```

---

# 17. Example Using `dev.auto.tfvars`

Create:

```text
dev.auto.tfvars
```

with:

```hcl
ec2_config = {
  v_size = 16
  v_type = "gp3"
}
```

Then:

```bash
terraform plan
```

automatically loads the file.

The resulting configuration is:

```text
16 GB gp3
```

No `-var` or `-var-file` is required.

---

# 18. Practical Commands

Initialize Terraform:

```bash
terraform init
```

Format:

```bash
terraform fmt
```

Validate:

```bash
terraform validate
```

---

### `-var` with plan

```bash
terraform plan -var='ec2_config={v_size=16,v_type="gp3"}'
```

### `-var` with apply

```bash
terraform apply -var='ec2_config={v_size=16,v_type="gp3"}'
```

---

### `dev.auto.tfvars` with plan

```bash
terraform plan
```

### `dev.auto.tfvars` with apply

```bash
terraform apply
```

---

### Explicit development file

```bash
terraform plan -var-file="dev.tfvars"
```

```bash
terraform apply -var-file="dev.tfvars"
```

---

### Explicit production file

```bash
terraform plan -var-file="prod.tfvars"
```

```bash
terraform apply -var-file="prod.tfvars"
```

---

# 🎯 Key Learning

This exercise demonstrates how Terraform variable values can be supplied and overridden.

```text
                    Terraform Variable
                           │
             ┌─────────────┴─────────────┐
             │                           │
        Default value              External value
                                         │
                    ┌────────────────────┼─────────────────┐
                    │                    │                 │
              Environment         Variable files       CLI
                TF_VAR_*          *.tfvars             -var
                                      │
                               -var-file
```

The most important distinction is:

```text
*.auto.tfvars
    ↓
Automatically loaded
```

while:

```text
-var-file
    ↓
Explicitly selected by the user
```

If multiple `.auto.tfvars` files exist, Terraform automatically loads them all. Therefore, for separate environments such as development and production, using:

```bash
terraform plan -var-file="dev.tfvars"
```

or:

```bash
terraform plan -var-file="prod.tfvars"
```

is clearer because you explicitly select the desired environment.

The practical override demonstrated in this project is:

```text
Default ec2_config
8 GB gp3
      ↓
Override
16 GB gp3
```

The Terraform resource itself does not need to be changed just to change the volume configuration.
