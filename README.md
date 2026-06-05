## Setup

### Prerequisites

* Terraform installed
* AWS CLI installed
* AWS Account
* AWS Access Key and Secret Key

### Create `.env` File

Create a `.env` file in the project root:

```env
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
export AWS_DEFAULT_REGION=ap-south-1
```

> The `.env` file contains sensitive AWS credentials and is excluded from Git using `.gitignore`.

### Load Environment Variables

```bash
source .env
```

Verify:

```bash
echo $AWS_ACCESS_KEY_ID
```

### Verify AWS Access

```bash
aws sts get-caller-identity
```

> **Note:** After running `source .env`, the AWS credentials are available in the current terminal session. There is no need to run `aws configure`. You can directly execute AWS CLI commands and Terraform commands using the credentials loaded from the `.env` file.

### Terraform Commands

```bash
terraform init
terraform validate
terraform plan
terraform apply
terraform destroy
```
