output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.website.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.website.arn
}

output "website_endpoint" {
  description = "S3 website endpoint"
  value       = aws_s3_bucket_website_configuration.website.website_endpoint
}

output "website_url" {
  description = "URL of the static website"
  value       = "http://${aws_s3_bucket_website_configuration.website.website_endpoint}"
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID (if enabled)"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.website[0].id : null
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name (if enabled)"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.website[0].domain_name : null
}

output "cloudfront_url" {
  description = "CloudFront HTTPS URL (if enabled)"
  value       = var.enable_cloudfront ? "https://${aws_cloudfront_distribution.website[0].domain_name}" : null
}

output "custom_domain" {
  description = "Custom domain name (if configured)"
  value       = var.custom_domain != "" ? var.custom_domain : null
}

output "route53_record" {
  description = "Route53 record created (if configured)"
  value       = var.enable_cloudfront && var.custom_domain != "" && var.route53_zone_id != "" ? "A record for ${var.custom_domain} pointing to CloudFront" : null
}
