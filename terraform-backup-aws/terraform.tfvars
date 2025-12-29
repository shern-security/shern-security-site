# Example terraform.tfvars file
# Copy this to terraform.tfvars and customize with your values

# Required: S3 bucket name (must be globally unique)
bucket_name = "shern-security-website-2025"

# Optional: AWS region
aws_region = "us-east-1"

# Optional: Environment
environment = "production"

# Optional: Enable CloudFront CDN
enable_cloudfront = true

# Optional: CloudFront price class (only used if enable_cloudfront = true)
cloudfront_price_class = "PriceClass_100"

# Optional: Custom domain (requires ACM certificate and Route53)
custom_domain = "shernsecurity.com"
acm_certificate_arn = "arn:aws:acm:us-east-1:623709041819:certificate/6f12070d-40b0-4745-a0f5-5fda171d9af3"
route53_zone_id = "Z01411602C09T40UHKCF8"
