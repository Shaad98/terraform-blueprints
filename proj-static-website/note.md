# 🚀 Terraform AWS S3 Static Website

A simple static website deployed to **AWS S3 using Terraform**.

This project is created as a hands-on learning project to understand **Terraform, AWS S3, Infrastructure as Code (IaC), resource dependencies, bucket policies, public access configuration, and Terraform outputs**.

---

## 🛠️ Technologies Used

* **Terraform**
* **AWS S3**
* **AWS Provider**
* **Random Provider**
* HTML
* CSS
* JavaScript

---

## 📁 Project Structure

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

### Terraform Files

| File           | Purpose                                                                             |
| -------------- | ----------------------------------------------------------------------------------- |
| `main.tf`      | Defines S3 bucket, objects, public access, bucket policy, and website configuration |
| `provider.tf`  | Configures the AWS provider                                                         |
| `variables.tf` | Defines configurable Terraform variables                                            |
| `outputs.tf`   | Displays useful information after deployment                                        |

### Website Files

| File         | Purpose            |
| ------------ | ------------------ |
| `index.html` | Main webpage       |
| `style.css`  | Website styling    |
| `script.js`  | Website JavaScript |

---

## 🏗️ Infrastructure Created

Terraform provisions the following AWS resources:

```text
Terraform
    │
    ├── Random ID
    │
    └── S3 Bucket
          │
          ├── index.html
          ├── style.css
          └── script.js
          │
          ├── Public Access Configuration
          │
          ├── Bucket Policy
          │
          └── Static Website Configuration
```

### Resources

#### 1. Random ID

A random suffix is generated to make the S3 bucket name globally unique.

```hcl
resource "random_id" "bucket_suffix" {
  byte_length = 8
}
```

The generated value is appended to the bucket name.

Example:

```text
my-bucket-terraform-static-hosting-a1b2c3d4
```

---

#### 2. S3 Bucket

Creates the S3 bucket used to host the static website.

```hcl
resource "aws_s3_bucket" "static_website"
```

The bucket is given a unique name using the generated random ID.

---

#### 3. Website Files

Terraform uploads the following files to S3:

```text
index.html
style.css
script.js
```

Each object is configured with the appropriate content type:

```text
index.html → text/html
style.css  → text/css
script.js  → text/javascript
```

---

#### 4. Public Access Block

S3 public-access blocking is configured to allow the bucket to be used for public static website hosting.

```hcl
resource "aws_s3_bucket_public_access_block" "static_website"
```

---

#### 5. S3 Bucket Policy

A bucket policy allows public read access to objects.

The policy grants:

```text
s3:GetObject
```

to:

```text
Principal = "*"
```

This allows users to access the website files from the internet.

> ⚠️ This configuration is intended for learning purposes. For production applications, consider using a private S3 bucket behind Amazon CloudFront with Origin Access Control (OAC).

---

#### 6. Static Website Configuration

S3 is configured to serve:

```text
index.html
```

as the default website document.

---

## 📤 Terraform Outputs

After deployment, Terraform provides useful outputs such as:

```text
s3_bucket_name
s3_bucket_arn
s3_bucket_region
static_website_endpoint
index_html_url
```

The most useful output is:

```text
static_website_endpoint
```

which provides the S3 static website URL.

---

# 🚀 Getting Started

## 1. Clone the Repository

```bash
git clone <repository-url>
cd terraform-static-website
```

---

## 2. Configure AWS Credentials

Make sure AWS credentials are configured before running Terraform.

For example:

```bash
aws configure
```

Verify the configuration:

```bash
aws sts get-caller-identity
```

---

## 3. Initialize Terraform

Initialize the Terraform working directory and download the required providers.

```bash
terraform init
```

---

## 4. Format Terraform Files

Format the Terraform configuration:

```bash
terraform fmt
```

---

## 5. Validate Configuration

Check whether the Terraform configuration is syntactically valid.

```bash
terraform validate
```

Expected result:

```text
Success! The configuration is valid.
```

---

## 6. Review the Execution Plan

Before creating resources, review what Terraform intends to create.

```bash
terraform plan
```

---

## 7. Deploy the Infrastructure

Apply the Terraform configuration:

```bash
terraform apply
```

Enter:

```text
yes
```

when Terraform asks for confirmation.

---

## 8. View Outputs

After deployment:

```bash
terraform output
```

To display only the website endpoint:

```bash
terraform output static_website_endpoint
```

You can open the returned URL in a browser to access the website.

---

# 🧹 Destroy Infrastructure

When you finish experimenting, remove the AWS resources created by Terraform:

```bash
terraform destroy
```

Confirm with:

```text
yes
```

This is important when using AWS learning projects because it prevents unnecessary resources from remaining active.

---

# 🧠 Terraform Concepts Practiced

This project demonstrates the following Terraform concepts:

* Terraform provider configuration
* Required providers
* Provider version constraints
* Input variables
* Resource blocks
* Resource dependencies
* `random_id`
* AWS S3
* S3 objects
* S3 bucket policies
* S3 public access configuration
* S3 static website hosting
* Terraform outputs
* `path.module`
* `terraform init`
* `terraform fmt`
* `terraform validate`
* `terraform plan`
* `terraform apply`
* `terraform destroy`

---

# 🔑 Important Terraform Concepts

### `path.module`

`path.module` refers to the filesystem path of the current Terraform module.

For example:

```hcl
source = "${path.module}/index.html"
```

This tells Terraform to locate `index.html` relative to the current module.

---

### Resource References

Terraform resources can reference attributes from other resources.

For example:

```hcl
bucket = aws_s3_bucket.static_website.id
```

Terraform understands that the S3 object depends on the S3 bucket.

---

### Explicit Dependency

The bucket policy explicitly depends on the public access configuration:

```hcl
depends_on = [
  aws_s3_bucket_public_access_block.static_website
]
```

This ensures Terraform processes the resources in the required order.

---

# ⚠️ Security Note

This project intentionally makes the S3 website publicly readable.

The bucket policy allows:

```text
s3:GetObject
```

for public users.

Do **not** use this exact architecture for sensitive or private data.

For a production static website, a more secure architecture is:

```text
User
  │
  ▼
CloudFront
  │
  ▼
Private S3 Bucket
  │
  └── Origin Access Control (OAC)
```

---

# 🎯 Learning Objective

The main objective of this project is to understand how **Infrastructure as Code** can be used to provision AWS infrastructure instead of manually creating resources through the AWS Management Console.

Instead of manually:

```text
Create S3 Bucket
       ↓
Upload Files
       ↓
Configure Public Access
       ↓
Create Bucket Policy
       ↓
Enable Website Hosting
```

Terraform manages the entire infrastructure through code:

```text
Terraform Configuration
          ↓
      terraform apply
          ↓
      AWS Resources
          ↓
    Static Website
```

---

## 📌 Useful Commands

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform output
terraform destroy
```

---

## 📜 License

This project is created for educational and learning purposes.
