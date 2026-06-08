# Terraform AWS S3 Bucket

## Overview

This project provisions an AWS S3 bucket using Terraform, with a unique name generated via the `random_id` provider and an S3 object upload.

---

## Resources

| Resource | Description |
|---|---|
| `aws_s3_bucket` | Creates the S3 bucket with a unique random name |
| `random_id` | Generates a unique hex suffix for the bucket name |
| `aws_s3_object` | Uploads a local file (`program.txt`) to the bucket as `main.txt` |

---

## ⚠️ Important AWS Rule

S3 bucket names must follow strict rules:
- ❌ No underscores (`_`) allowed
- ✔ Only lowercase letters (a-z)
- ✔ Numbers (0-9) allowed
- ✔ Hyphens (`-`) allowed

---

## Naming Convention

Bucket names are dynamically generated using a `random_id` suffix to ensure global uniqueness:

```hcl
bucket = "my-bucket-${random_id.random_id.hex}"
```

**Example output:** `my_bucket_a3f9c12b4e67d801`

This avoids S3 naming conflicts across all AWS accounts worldwide.

---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) installed
- AWS account with S3 permissions
- AWS **Access Key** and **Secret Access Key** (see setup below)
- A local file `program.txt` in the project root (will be uploaded as `main.txt`)

---

## 🔐 AWS Credentials Setup

Instead of hardcoding credentials, use a `.env` file to keep secrets out of your code.

### Step 1 — Create a `.env` file in the project root

```bash
# .env
export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_HERE"
export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_ACCESS_KEY_HERE"
export AWS_DEFAULT_REGION="us-east-1"
```

> **⚠️ Never commit `.env` to Git.** Add it to `.gitignore` immediately:
> ```bash
> echo ".env" >> .gitignore
> ```

### Step 2 — Load the credentials into your shell

```bash
source .env
```

### Step 3 — Verify credentials are loaded

```bash
echo $AWS_ACCESS_KEY_ID
```

You should see your key printed. Terraform will automatically pick up these environment variables.

---

## Variables

| Variable | Description | Default |
|---|---|---|
| `region` | AWS region for resource provisioning | `us-east-1` |

---

## Outputs

| Output | Description |
|---|---|
| `bucket_name` | The name of the created S3 bucket |
| `random_id` | The base64 URL-encoded value of the random ID |

> ⚠️ **Note:** Your current config has a duplicate `bucket_name` output block. Remove one to avoid Terraform errors:
> ```hcl
> # Remove this duplicate block
> output "bucket_name" {
>   value = aws_s3_bucket.my_bucket.bucket
> }
> ```

---

## ⚠️ Important Terraform Rules

- Always run `terraform init` after adding or changing a provider:

```bash
terraform init
```

- Always load your `.env` before running any Terraform command:

```bash
source .env
```

- Validate your configuration before planning:

```bash
terraform validate
```

---

## 🚀 How to Run

```bash
# 1. Load AWS credentials
source .env

# 2. Initialize providers and modules
terraform init

# 3. Validate configuration
terraform validate

# 4. Preview infrastructure changes
terraform plan

# 5. Apply and provision resources
terraform apply

# 6. Destroy all resources (optional)
terraform destroy
```

---

## Project Structure

```
.
├── main.tf          # S3 bucket, random ID, S3 object resources
├── variables.tf     # Input variables (region)
├── outputs.tf       # Output values (bucket_name, random_id)
├── .env             # AWS credentials (DO NOT commit)
├── .gitignore       # Should include .env
├── program.txt      # File uploaded to S3 as main.txt
└── README.md
```

---

## .gitignore (Recommended)

```gitignore
.env
.terraform/
.terraform.lock.hcl
terraform.tfstate
terraform.tfstate.backup
*.tfvars
```