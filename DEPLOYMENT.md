# Deployment Guide - Shern Security Website

Complete guide to deploying your Astro static site to AWS S3 with automated GitHub Actions deployment.

## Overview

This site uses:
- **Astro 5** - Static site generator
- **AWS S3** - Static website hosting
- **Terraform** - Infrastructure as Code
- **GitHub Actions** - Automated CI/CD deployment

## Prerequisites

### 1. AWS Account Setup

**Required Accounts:**
- Active AWS account with billing enabled
- AWS IAM user with appropriate permissions (see below)

**Required AWS Permissions for Infrastructure (Terraform):**

You need an IAM user/role with these permissions to create infrastructure:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:CreateBucket",
        "s3:PutBucketPolicy",
        "s3:PutBucketWebsite",
        "s3:PutBucketPublicAccessBlock",
        "s3:PutBucketVersioning",
        "s3:ListBucket",
        "s3:GetBucketPolicy",
        "s3:GetBucketWebsite",
        "s3:DeleteBucket",
        "s3:PutObject",
        "s3:GetObject",
        "s3:PutBucketEncryption"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:CreateTable",
        "dynamodb:DescribeTable",
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": "arn:aws:dynamodb:*:*:table/terraform-state-lock"
    }
  ]
}
```

**Required AWS Permissions for Deployment (GitHub Actions):**

Create a separate IAM user for CI/CD with minimal permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:DeleteObject"
      ],
      "Resource": [
        "arn:aws:s3:::shern-security-website-2025",
        "arn:aws:s3:::shern-security-website-2025/*"
      ]
    }
  ]
}
```

### 2. Install Required Tools

**Install AWS CLI:**
```bash
sudo apt install awscli
# Or on Mac: brew install awscli
```

**Configure AWS CLI:**
```bash
aws configure
```

Enter when prompted:
- **AWS Access Key ID**: Your IAM user access key
- **AWS Secret Access Key**: Your IAM user secret key
- **Default region**: `us-east-1`
- **Default output format**: `json`

**Verify Configuration:**
```bash
aws sts get-caller-identity
```

### 3. Install Terraform (if not installed)

```bash
# Download and install Terraform
wget https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_linux_amd64.zip
unzip terraform_1.7.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform version
```

## Step 1: Setup Remote State Backend (CI/CD Only)

**Note:** If you're using AWS SSO (`aws login`), skip this step and use local state for development. The remote backend is automatically enabled for GitHub Actions deployments.

**For CI/CD with IAM user credentials:**

### 1.1 Create State Storage

```bash
# Create S3 bucket for state (change bucket name if needed)
aws s3 mb s3://shern-terraform-state-2025

# Enable versioning (recommended for state recovery)
aws s3api put-bucket-versioning \
  --bucket shern-terraform-state-2025 \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket shern-terraform-state-2025 \
  --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

**Note:** Remote backend is automatically enabled by the GitHub Actions workflow. Local development uses local state.

## Step 2: Create AWS Infrastructure

### 2.1 Configure Terraform Variables

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
# Required: S3 bucket name (must be globally unique)
bucket_name = "shern-security-website-2025"  # Change if needed

# Optional: AWS region
aws_region = "us-east-1"

# Optional: Environment
environment = "production"

# Optional: Enable CloudFront CDN (recommended for production)
enable_cloudfront = false  # Set to true for HTTPS and better performance
```

### 2.2 Initialize and Apply Terraform

**Local Development (AWS SSO):**
```bash
# Initialize with local state
terraform init

# Preview changes
terraform plan

# Create infrastructure (type 'yes' when prompted)
terraform apply
```

**CI/CD Deployment:**
- Infrastructure is deployed via GitHub Actions workflow
- Go to repository → Actions → "Deploy Infrastructure with Terraform"
- Select "apply" and run workflow
- Remote state is automatically enabled

### 2.3 Save Terraform Outputs

```bash
# Save these values - you'll need them for GitHub Actions
terraform output bucket_name
terraform output website_url
```

**Example output:**
```
bucket_name = "shern-security-website-2025"
website_url = "http://shern-security-website-2025.s3-website-us-east-1.amazonaws.com"
```

## Step 3: GitHub Repository Setup

### 3.1 Create GitHub Repository

1. Go to https://github.com/new
2. Create repository: `shern-sec-site` (or your preferred name)
3. Don't initialize with README (we already have one)

### 3.2 Push Code to GitHub

```bash
cd /home/jonshern/src/skunkworks/shern-sec-site

# Initialize git if not already done
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit - Shern Security website"

# Add remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/shern-sec-site.git

# Push to GitHub
git branch -M main
git push -u origin main
```

## Step 4: Configure GitHub Secrets

### 4.1 Create Deployment IAM User

1. Go to AWS Console → IAM → Users
2. Click "Create user"
3. Username: `github-actions-deploy`
4. Attach the deployment policy (S3 permissions only - see Prerequisites)
5. Create access key for "Application running outside AWS"
6. **Save the Access Key ID and Secret Access Key**

### 4.2 Add GitHub Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions

Add these secrets:

| Secret Name | Value | Example |
|------------|-------|---------|
| `AWS_ACCESS_KEY_ID` | IAM user access key | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | IAM user secret key | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `AWS_REGION` | AWS region | `us-east-1` |
| `S3_BUCKET_NAME` | From terraform output | `shern-security-website-2025` |

**To add secrets:**
1. Click "New repository secret"
2. Enter name and value
3. Click "Add secret"
4. Repeat for all 4 secrets

## Step 5: Verify GitHub Actions Workflow

The workflow file already exists at `.github/workflows/deploy.yml`

**What it does:**
1. Triggers on push to `main` branch
2. Checks out code
3. Installs Node.js dependencies
4. Builds the static site (`npm run build`)
5. Syncs `dist/` folder to S3 bucket
6. Makes all files public

**Workflow file:**
```yaml
name: Deploy to AWS S3

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Build site
        run: npm run build
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ secrets.AWS_REGION }}
      
      - name: Deploy to S3
        run: |
          aws s3 sync dist/ s3://${{ secrets.S3_BUCKET_NAME }} --delete
          aws s3 cp s3://${{ secrets.S3_BUCKET_NAME }} s3://${{ secrets.S3_BUCKET_NAME }} --recursive --metadata-directive REPLACE --cache-control max-age=0,no-cache,no-store,must-revalidate --content-type "text/html" --exclude "*" --include "*.html"
```

## Step 6: Deploy Your Site

### 6.1 Trigger Deployment

Push any change to trigger deployment:

```bash
# Make a small change
echo "" >> README.md

# Commit and push
git add .
git commit -m "Trigger deployment"
git push
```

### 6.2 Monitor Deployment

1. Go to GitHub repository → Actions tab
2. Click on the running workflow
3. Watch the deployment progress
4. Verify all steps complete successfully

### 6.3 Access Your Site

Once deployment completes, visit your website URL (from terraform output):

```
http://shern-security-website-2025.s3-website-us-east-1.amazonaws.com
```

## Step 7: Content Updates

### 7.1 Local Development

```bash
# Start development server
npm run dev

# View at http://localhost:4321/
```

### 7.2 Add New Blog Posts

1. Create new markdown file in `src/content/post/`:

```bash
cd src/content/post
nano my-new-article.md
```

2. Add frontmatter:

```markdown
---
publishDate: 2025-01-15T00:00:00Z
title: 'My New Article Title'
excerpt: 'Brief description of the article'
image: 'https://images.unsplash.com/photo-...'
category: 'Security'
tags:
  - security
  - automation
---

Your article content here...
```

3. Commit and push:

```bash
git add src/content/post/my-new-article.md
git commit -m "Add new article: My New Article Title"
git push
```

GitHub Actions automatically deploys within 2-3 minutes.

## Troubleshooting

### AWS CLI Not Configured
```bash
aws configure
# Enter your credentials
```

### Terraform State Issues
```bash
cd terraform
terraform init -reconfigure
```

### Build Fails
```bash
# Test build locally
npm run build

# Check for errors in console
```

### S3 Sync Fails
- Verify IAM user has S3 permissions
- Check bucket name matches in GitHub secrets
- Ensure AWS credentials are correct

### Site Not Loading
- Check S3 bucket policy allows public read
- Verify static website hosting is enabled
- Wait 5-10 minutes for DNS propagation

## Costs

**Estimated Monthly Costs:**

- **S3 Storage**: ~$0.023 per GB/month
- **S3 Requests**: Minimal for static sites (~$0.01/month)
- **Data Transfer**: First 100 GB/month free, then ~$0.09/GB

**Example for small site:**
- 500 MB storage: ~$0.01
- 10,000 page views: ~$0.02
- **Total: ~$0.03/month**

## Advanced Options

### Enable CloudFront CDN

Edit `terraform/terraform.tfvars`:

```hcl
enable_cloudfront = true
```

Run:
```bash
cd terraform
terraform apply
```

Benefits:
- HTTPS support
- Better global performance
- Lower costs for high traffic

### Custom Domain

1. Get ACM certificate in us-east-1
2. Update `terraform.tfvars`:

```hcl
enable_cloudfront = true
custom_domain = "shernsecurity.com"
acm_certificate_arn = "arn:aws:acm:us-east-1:123456789:certificate/abc-123"
route53_zone_id = "Z1234567890ABC"
```

3. Apply changes:

```bash
terraform apply
```

## Security Best Practices

1. **Never commit AWS credentials** - Always use GitHub Secrets
2. **Use separate IAM users** - One for infrastructure, one for deployment
3. **Enable MFA** on AWS account
4. **Rotate access keys** every 90 days
5. **Review IAM policies** - Use least privilege principle
6. **Enable CloudTrail** - Audit AWS API calls
7. **Monitor costs** - Set up billing alerts

## Support

For issues:
1. Check GitHub Actions logs
2. Review Terraform output
3. Verify AWS credentials
4. Check [terraform/README.md](terraform/README.md) for details

---

**Site successfully deployed! 🎉**

Your website is now live and will automatically update whenever you push to the main branch.
