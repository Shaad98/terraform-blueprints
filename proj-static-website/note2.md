# 🚀 Terraform AWS S3 Static Website Hosting

A hands-on Terraform practical for provisioning an **AWS S3 bucket and deploying a static website using Infrastructure as Code (IaC)**.

This practical covers the complete workflow from configuring the AWS provider and creating resources to uploading website files, configuring public access, enabling S3 static website hosting, retrieving outputs, and destroying the infrastructure.

---

## 🎯 Objective

The objective of this practical is to learn how to:

* Configure the AWS provider using Terraform.
* Define Terraform variables.
* Use Terraform's `random` provider.
* Create an S3 bucket using Terraform.
* Upload HTML, CSS, and JavaScript files to S3.
* Configure S3 public access.
* Create an S3 bucket policy.
* Enable S3 static website hosting.
* Use `path.module` for local file references.
* Create Terraform outputs.
* Understand Terraform resource dependencies.
* Deploy and destroy AWS infrastructure using Terraform CLI.

---

# 📁 Project Structure

```text
terraform-static-website/
│
├── main.tf
├── provider.tf
├── variables.tf
├── outputs.tf
│
├── index.html
├── style.css
└── script.js
```

---

# 🏗️ Architecture

```text
                    Terraform
                        │
                        ▼
                AWS Provider
                        │
                        ▼
                ┌──────────────┐
                │   S3 Bucket  │
                └──────┬───────┘
                       │
          ┌────────────┼────────────┐
          │            │            │
          ▼            ▼            ▼
     index.html    style.css    script.js
          │            │            │
          └────────────┼────────────┘
                       │
                       ▼
              Public Access Block
                       │
                       ▼
                Bucket Policy
                       │
                       ▼
             Static Website Config
                       │
                       ▼
                    Browser
```

---

# 1️⃣ Terraform Configuration

The required providers are defined in `main.tf`.

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
}
```

### Providers Used

| Provider | Purpose                                          |
| -------- | ------------------------------------------------ |
| AWS      | Creates and manages AWS infrastructure           |
| Random   | Generates a unique suffix for the S3 bucket name |

The random provider is required because S3 bucket names must be **globally unique**.

---

# 2️⃣ AWS Provider Configuration

`provider.tf`:

```hcl
provider "aws" {
  region = var.region
}
```

The AWS region is not hardcoded directly into the provider. Instead, it is obtained from the Terraform variable:

```hcl
var.region
```

---

# 3️⃣ Terraform Variable

`variables.tf`:

```hcl
variable "region" {
  description = "AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}
```

This allows the AWS region to be changed without modifying the provider configuration.

For example:

```bash
terraform apply -var="region=ap-south-1"
```

---

# 4️⃣ Generate a Unique Bucket Suffix

```hcl
resource "random_id" "bucket_suffix" {
  byte_length = 8
}
```

The generated value is used while creating the S3 bucket.

For example:

```text
my-bucket-terraform-static-hosting-a1b2c3d4
```

This helps avoid S3 bucket-name conflicts.

---

# 5️⃣ Create the S3 Bucket

```hcl
resource "aws_s3_bucket" "static_website" {
  bucket = "my-bucket-terraform-static-hosting-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "terraform-static-website"
    Environment = "learning"
    ManagedBy   = "Terraform"
  }
}
```

Terraform creates the S3 bucket and assigns tags to identify the resource.

---

# 6️⃣ Upload Website Files

The website contains three files:

```text
index.html
style.css
script.js
```

## HTML

```hcl
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.static_website.id
  key          = "index.html"
  source       = "${path.module}/index.html"
  content_type = "text/html"
}
```

## CSS

```hcl
resource "aws_s3_object" "style_css" {
  bucket       = aws_s3_bucket.static_website.id
  key          = "style.css"
  source       = "${path.module}/style.css"
  content_type = "text/css"
}
```

## JavaScript

```hcl
resource "aws_s3_object" "script_js" {
  bucket       = aws_s3_bucket.static_website.id
  key          = "script.js"
  source       = "${path.module}/script.js"
  content_type = "text/javascript"
}
```

---

# 🔎 Understanding `path.module`

`path.module` is a Terraform built-in expression that represents the filesystem path of the **current Terraform module**.

For example:

```hcl
source = "${path.module}/index.html"
```

If the Terraform module is located at:

```text
/home/shaad/terraform-static-website/
```

Terraform resolves:

```text
${path.module}/index.html
```

to:

```text
/home/shaad/terraform-static-website/index.html
```

This is useful for referencing files stored with the Terraform module.

---

# 7️⃣ Configure S3 Public Access

```hcl
resource "aws_s3_bucket_public_access_block" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
```

S3 has public-access protection mechanisms.

Since this practical is using S3 directly as a public static website, public access needs to be permitted.

---

# 8️⃣ Create S3 Bucket Policy

```hcl
resource "aws_s3_bucket_policy" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  depends_on = [
    aws_s3_bucket_public_access_block.static_website
  ]

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"

        Action = [
          "s3:GetObject"
        ]

        Resource = "${aws_s3_bucket.static_website.arn}/*"
      }
    ]
  })
}
```

### What does this policy do?

It allows anyone to read objects from the bucket.

The important permission is:

```text
s3:GetObject
```

The policy does **not** grant:

```text
s3:PutObject
s3:DeleteObject
```

Therefore, the public can read website files but cannot upload or delete them through this policy.

---

# 9️⃣ Why `depends_on`?

The bucket policy depends on the public-access configuration.

```hcl
depends_on = [
  aws_s3_bucket_public_access_block.static_website
]
```

This explicitly tells Terraform:

```text
Create S3 Bucket
       ↓
Configure Public Access
       ↓
Create Bucket Policy
```

It helps ensure that AWS processes the required access configuration before Terraform applies the public bucket policy.

---

# 🔟 Enable Static Website Hosting

```hcl
resource "aws_s3_bucket_website_configuration" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  index_document {
    suffix = "index.html"
  }
}
```

This tells S3:

> When a user opens the website, use `index.html` as the default document.

---

# 1️⃣1️⃣ Terraform Outputs

`outputs.tf`:

```hcl
output "s3_bucket_name" {
  description = "Name of the S3 bucket hosting the static website."
  value       = aws_s3_bucket.static_website.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket."
  value       = aws_s3_bucket.static_website.arn
}

output "s3_bucket_region" {
  description = "AWS region where the S3 bucket is located."
  value       = aws_s3_bucket.static_website.region
}

output "static_website_endpoint" {
  description = "S3 static website endpoint."
  value       = "http://${aws_s3_bucket_website_configuration.static_website.website_endpoint}"
}

output "index_html_url" {
  description = "URL of the index.html object."
  value       = "http://${aws_s3_bucket_website_configuration.static_website.website_endpoint}/index.html"
}
```

After deployment:

```bash
terraform output
```

Terraform displays the information about the created infrastructure.

---

# 🧪 Terraform Practical Workflow

The practical was performed using the standard Terraform workflow.

## Step 1 — Initialize Terraform

```bash
terraform init
```

This:

* Initializes the Terraform working directory.
* Downloads required providers.
* Creates the `.terraform` directory.
* Creates or updates `.terraform.lock.hcl`.

---

## Step 2 — Format Configuration

```bash
terraform fmt
```

This formats Terraform files according to Terraform's standard formatting rules.

---

## Step 3 — Validate Configuration

```bash
terraform validate
```

This checks whether the Terraform configuration is syntactically and structurally valid.

Expected result:

```text
Success! The configuration is valid.
```

---

## Step 4 — Review Execution Plan

```bash
terraform plan
```

This shows what Terraform intends to create, modify, or destroy.

---

## Step 5 — Create Infrastructure

```bash
terraform apply
```

Terraform asks for confirmation:

```text
Do you want to perform these actions?
```

Enter:

```text
yes
```

Terraform then creates:

```text
Random ID
    ↓
S3 Bucket
    ↓
Website Files
    ↓
Public Access Configuration
    ↓
Bucket Policy
    ↓
Website Configuration
```

---

## Step 6 — Check Outputs

```bash
terraform output
```

Or retrieve the website endpoint directly:

```bash
terraform output static_website_endpoint
```

Open the returned URL in a browser to access the static website.

---

# 🔄 Terraform Dependency Flow

Terraform automatically detects dependencies from resource references.

For example:

```hcl
bucket = aws_s3_bucket.static_website.id
```

creates a dependency between the S3 object and the S3 bucket.

Therefore Terraform understands:

```text
S3 Bucket
    ↓
S3 Objects
```

Similarly:

```hcl
bucket = aws_s3_bucket.static_website.id
```

is used by the website configuration and bucket policy.

Terraform builds a dependency graph and uses it to determine the correct creation order.

---

# 🧹 Destroy the Infrastructure

After completing the practical, the infrastructure can be removed using:

```bash
terraform destroy
```

Confirm with:

```text
yes
```

Terraform then removes the resources it manages.

---

# 🔐 Security Consideration

This practical intentionally makes the S3 website publicly readable.

```hcl
Principal = "*"
```

with:

```hcl
Action = [
  "s3:GetObject"
]
```

is used to allow public access to website files.

This configuration is suitable for learning a basic S3 static website, but it is **not the recommended architecture for production applications**.

A production architecture would generally use:

```text
User
  │
  ▼
CloudFront
  │
  ▼
Private S3 Bucket
  │
  ▼
Origin Access Control (OAC)
```

---

# 📚 Concepts Learned

Through this practical, the following concepts were implemented:

### Terraform

* Terraform configuration
* Providers
* Provider version constraints
* Variables
* Resources
* Resource references
* Implicit dependencies
* Explicit dependencies
* `depends_on`
* `path.module`
* Outputs
* Terraform state
* Terraform initialization
* Terraform formatting
* Terraform validation
* Terraform planning
* Terraform apply
* Terraform destroy

### AWS

* S3 bucket
* S3 objects
* S3 bucket policy
* S3 public access block
* S3 static website hosting
* IAM policy structure
* S3 ARN
* AWS regions

---

# 💡 Practical Result

The final result is a static website hosted on AWS S3 where the complete infrastructure is created and managed through Terraform.

Instead of manually configuring AWS resources through the AWS Console:

```text
Manual AWS Configuration
        ↓
S3 Bucket
        ↓
Upload Files
        ↓
Configure Permissions
        ↓
Configure Website
```

the same infrastructure can be reproduced using:

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

This demonstrates the core idea of **Infrastructure as Code (IaC)**:

> Infrastructure is defined as code, version-controlled, reproducible, and managed using Terraform.

---

# 📝 Commit

```text
feat(terraform): provision S3 static website with Terraform
```
