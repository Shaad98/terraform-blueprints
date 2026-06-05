Here’s your **clean final `README.md` code** you can directly copy-paste 👇

```md id="rm1tf2"
# Terraform AWS EC2 Practice

This project demonstrates Infrastructure as Code (IaC) using Terraform by provisioning an AWS EC2 instance.

---

## 🚀 What This Project Does

- Configures AWS provider using Terraform
- Creates an EC2 instance in AWS
- Uses variables to avoid hardcoding values
- Demonstrates basic Terraform workflow (init → plan → apply → destroy)

---

## 📁 Project Structure

```text
terraform-blueprints/
└── aws-ec2/
    ├── main.tf
    ├── provider.tf
    ├── variables.tf
    ├── outputs.tf
    ├── .env
    ├── .gitignore
    └── README.md
```

---

## ⚙️ Prerequisites

- Terraform installed
- AWS CLI installed
- AWS account
- AWS Access Key & Secret Key

---

## 🔐 Environment Setup

Create a `.env` file in the root directory:

```bash
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
export AWS_DEFAULT_REGION=us-east-1
````

> ⚠️ This file contains sensitive data and must NOT be pushed to GitHub.

---

## ▶️ Load Environment Variables

```bash
source .env
```

Verify AWS access:

```bash
aws sts get-caller-identity
```

---

## 🧱 Terraform Workflow

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Validate Configuration

```bash
terraform validate
```

### 3. Plan Infrastructure

```bash
terraform plan
```

### 4. Apply Changes

```bash
terraform apply
```

### 5. Destroy Infrastructure

```bash
terraform destroy
```

---

## 📦 Variables

This project uses Terraform variables to avoid hardcoding values.

* `region` → AWS region for deployment

Variables are defined in `variables.tf`.

Terraform automatically loads all `.tf` files in the same directory.

---

## 🧠 Key Concepts

* Terraform is declarative (order of code does NOT matter)
* All `.tf` files in a folder are loaded automatically
* Best practice: separate files for provider, variables, and resources
* `.terraform/`, `.tfstate`, and `.env` must be ignored in Git

```


