# Terraform Infrastructure for Shern Security Website

This directory contains Terraform configuration to provision and manage the AWS infrastructure for the Shern Security static website.

## What It Creates

- **S3 Bucket** - For static website hosting with public read access
- **S3 Website Configuration** - Enables static website hosting with index.html and 404.html
- **Bucket Policy** - Allows public read access to website content
- **CloudFront Distribution** (Optional) - CDN for better performance and HTTPS support
- **Route53 DNS Record** (Optional) - Custom domain configuration

## Prerequisites

1. **AWS Account** - Active AWS account with appropriate permissions
2. **AWS CLI** - Installed and configured with credentials
3. **Terraform** - Version 1.0 or higher installed

## Quick Start

### 1. Configure Variables

Create a `terraform.tfvars` file from the example:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and set your bucket name (must be globally unique):

```hcl
bucket_name = "your-unique-bucket-name"
aws_region  = "us-east-1"
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Preview Changes

```bash
terraform plan
```

### 4. Create Infrastructure

```bash
terraform apply
```

Type `yes` when prompted to create the resources.

### 5. Save Outputs

After creation, save the outputs for use in GitHub Actions:

```bash
terraform output bucket_name
terraform output cloudfront_distribution_id  # if enabled
```

## Configuration Options

### Basic Configuration (S3 Only)

```hcl
bucket_name = "shern-security-website"
aws_region  = "us-east-1"
```

This creates a basic S3-hosted website accessible via HTTP.

### With CloudFront CDN

```hcl
bucket_name       = "shern-security-website"
enable_cloudfront = true
```

This adds a CloudFront distribution for:
- HTTPS support
- Better performance via CDN
- Global content distribution

### With Custom Domain

```hcl
bucket_name         = "shern-security-website"
enable_cloudfront   = true
custom_domain       = "shernsecurity.com"
acm_certificate_arn = "arn:aws:acm:us-east-1:123456789:certificate/abc-123"
route53_zone_id     = "Z1234567890ABC"
```

**Prerequisites for custom domain:**
1. Domain registered and managed in Route53 (or DNS pointed to Route53)
2. ACM certificate created in `us-east-1` region for the domain
3. ACM certificate validated

## GitHub Actions Integration

After creating the infrastructure, add these secrets to your GitHub repository:

```bash
# Get the outputs
AWS_REGION=$(terraform output -raw aws_region)
S3_BUCKET_NAME=$(terraform output -raw bucket_name)

# If CloudFront is enabled
CLOUDFRONT_DISTRIBUTION_ID=$(terraform output -raw cloudfront_distribution_id)
```

Add to GitHub Secrets:
- `AWS_ACCESS_KEY_ID` - IAM user access key
- `AWS_SECRET_ACCESS_KEY` - IAM user secret key
- `AWS_REGION` - From terraform output
- `S3_BUCKET_NAME` - From terraform output
- `CLOUDFRONT_DISTRIBUTION_ID` - From terraform output (if using CloudFront)

## IAM Permissions

The IAM user for GitHub Actions needs these permissions:

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
        "arn:aws:s3:::your-bucket-name",
        "arn:aws:s3:::your-bucket-name/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudfront:CreateInvalidation"
      ],
      "Resource": "arn:aws:cloudfront::*:distribution/*"
    }
  ]
}
```

## Managing Infrastructure

### View Current State

```bash
terraform show
```

### Update Infrastructure

Modify `terraform.tfvars` or the `.tf` files, then:

```bash
terraform plan
terraform apply
```

### Destroy Infrastructure

⚠️ **Warning:** This will delete all resources including the S3 bucket and its contents.

```bash
terraform destroy
```

## Costs

### S3 Only
- S3 storage: ~$0.023 per GB/month
- S3 requests: Minimal for static sites
- Data transfer: First 100 GB/month free, then ~$0.09/GB

### With CloudFront
- CloudFront requests: ~$0.0075-0.016 per 10,000 requests
- CloudFront data transfer: First 1 TB/month free (12-month free tier), then ~$0.085/GB
- Generally lower costs for higher traffic sites

## Troubleshooting

### Bucket Name Already Exists
S3 bucket names must be globally unique. Change `bucket_name` in your `terraform.tfvars`.

### CloudFront Takes Time
CloudFront distributions can take 15-30 minutes to fully deploy.

### Custom Domain Certificate Issues
- ACM certificates for CloudFront must be in `us-east-1` region
- Certificate must be validated before use
- DNS changes can take time to propagate

## State Management

For production use, consider using remote state:

```hcl
terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "shern-security-website/terraform.tfstate"
    region = "us-east-1"
  }
}
```

Add this to `main.tf` in the `terraform` block.
