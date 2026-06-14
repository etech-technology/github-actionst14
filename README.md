# GitHub Actions → Amazon S3 Demo

A classroom-ready project that deploys static website files to an Amazon S3 bucket whenever code is pushed to the `main` branch.

## Architecture

```text
Developer
   |
   | git push
   v
GitHub Repository
   |
   | triggers
   v
GitHub Actions
   |
   | OIDC: assumes AWS IAM role
   v
Amazon S3 Bucket
   |
   v
Static website files
```

## What students learn

- GitHub Actions workflow triggers
- Jobs, steps, runners, variables, and secrets
- AWS authentication using OpenID Connect (OIDC)
- Least-privilege IAM permissions
- Deploying files with `aws s3 sync`
- Manual workflow execution
- Troubleshooting workflow logs

## Repository structure

```text
.
├── .github/workflows/deploy-to-s3.yml
├── terraform/
│   ├── main.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── terraform.tfvars.example
│   └── variables.tf
├── website/
│   ├── index.html
│   ├── styles.css
│   └── app.js
├── .gitignore
└── README.md
```

# Prerequisites

- AWS account
- AWS CLI configured locally
- Terraform 1.5 or later
- GitHub repository
- Permission to create S3 and IAM resources

# Part 1 — Create the GitHub repository

Create an empty GitHub repository and push this project into it.

```bash
git init
git add .
git commit -m "Initial GitHub Actions S3 demo"
git branch -M main
git remote add origin https://github.com/YOUR_GITHUB_USERNAME/YOUR_REPOSITORY.git
git push -u origin main
```

# Part 2 — Provision AWS resources

Terraform creates:

- Private S3 bucket
- S3 versioning and encryption
- GitHub OIDC identity provider
- IAM role for GitHub Actions
- Least-privilege S3 deployment policy

Copy the variables example:

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
aws_region        = "us-east-1"
bucket_name       = "replace-with-a-globally-unique-bucket-name"
github_owner      = "YOUR_GITHUB_USERNAME_OR_ORGANIZATION"
github_repository = "YOUR_REPOSITORY"
```

Deploy:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Record the outputs:

```bash
terraform output
```

# Part 3 — Add GitHub repository variables

In GitHub, open:

```text
Repository → Settings → Secrets and variables → Actions → Variables
```

Create these repository variables:

| Variable | Value |
|---|---|
| `AWS_REGION` | Terraform output `aws_region` |
| `AWS_ROLE_ARN` | Terraform output `github_actions_role_arn` |
| `S3_BUCKET_NAME` | Terraform output `s3_bucket_name` |

These are identifiers rather than passwords, so repository variables are suitable. OIDC avoids storing AWS access keys in GitHub.

# Part 4 — Run the deployment

Change any file under `website/`, commit it, and push:

```bash
git add website/
git commit -m "Update website"
git push origin main
```

Then open:

```text
GitHub repository → Actions → Deploy Website to Amazon S3
```

You can also open the workflow and select **Run workflow**.

# Workflow behavior

The workflow:

1. Checks out the repository.
2. Requests a GitHub OIDC token.
3. Exchanges it for temporary AWS credentials.
4. Confirms the AWS identity.
5. synchronizes `website/` to S3.
6. Verifies that objects exist in the bucket.
7. Writes a deployment summary.

The deployment command is:

```bash
aws s3 sync website/ "s3://${S3_BUCKET_NAME}" --delete
```

`--delete` removes bucket objects that no longer exist in the local `website/` directory.

# Classroom demo sequence

1. Show the files in `website/`.
2. Explain the workflow trigger.
3. Push the initial version.
4. Watch each GitHub Actions step.
5. Open the S3 bucket and show uploaded objects.
6. Modify the page heading.
7. Push again and show the updated object.
8. Delete one local file and explain `--delete`.
9. Run the workflow manually.
10. Intentionally use a wrong bucket variable and inspect the failure.
11. Correct the variable and rerun the failed workflow.

# Important security notes

- Do not store AWS access keys in the repository.
- The IAM trust policy restricts access to one GitHub repository and the `main` branch.
- The IAM permissions are limited to one S3 bucket.
- The bucket is private by default.
- The workflow uses temporary credentials through OIDC.
- For production, pin third-party actions to full commit SHAs and use GitHub environments with approvals.

# Optional: make the S3 website publicly accessible

This demo keeps the bucket private because that is safer for teaching authentication and deployment.

For a public production website, prefer CloudFront with Origin Access Control in front of the private S3 bucket. Avoid disabling S3 Block Public Access unless you explicitly understand and accept the exposure.

# Cleanup

```bash
cd terraform
terraform destroy
```

The bucket must be empty before Terraform can delete it. To empty it:

```bash
aws s3 rm "s3://YOUR_BUCKET_NAME" --recursive
terraform destroy
```
