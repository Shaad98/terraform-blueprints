# Terraform AWS EC2 Practice

This project demonstrates the basics of Terraform by provisioning an AWS EC2 instance.

## What This Project Does

* Configures the AWS provider
* Uses Terraform to manage infrastructure as code
* Creates an EC2 instance (`t2.micro`) in AWS
* Applies a custom tag (`Name = "MyWebServer"`)
* Maintains infrastructure state using Terraform state files

## Prerequisites

* Terraform installed
* AWS CLI installed
* AWS Account
* AWS Access Key and Secret Key

## Create `.env` File

Create a `.env` file in the project root:

```env
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
export AWS_DEFAULT_REGION=us-east-1
```

> The `.env` file contains sensitive AWS credentials and is excluded from Git using `.gitignore`.

## Load Environment Variables

```bash
source .env
```

Verify AWS access:

```bash
aws sts get-caller-identity
```

> **Note:** After running `source .env`, there is no need to execute `aws configure`. AWS CLI and Terraform automatically use the credentials loaded from the environment variables.

## Terraform Workflow

### 1. Initialize Terraform

Downloads the required provider plugins and initializes the working directory. This step is mandatory before running any Terraform commands.

```bash
terraform init
```

### 2. Validate Configuration

Checks the Terraform configuration for syntax errors and basic issues.

```bash
terraform validate
```

### 3. Review Execution Plan

Shows the changes Terraform will make before creating resources.

```bash
terraform plan
```

### 4. Create Infrastructure

Creates the AWS resources defined in the configuration and generates the Terraform state file.

```bash
terraform apply
```

To skip confirmation:

```bash
terraform apply -auto-approve
```

### 5. Destroy Infrastructure

Removes all resources managed by Terraform and updates the state file accordingly.

```bash
terraform destroy
```

To skip confirmation:

```bash
terraform destroy -auto-approve
```

## Terraform State

Terraform maintains a state file (`terraform.tfstate`) that tracks the resources it manages. This state file enables Terraform to determine what infrastructure already exists and what changes are required during future deployments.
