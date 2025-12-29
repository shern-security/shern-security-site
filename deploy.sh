#!/bin/bash
set -e

# Deployment script for Shern Security Website
# Builds the Astro site and deploys to AWS S3 with CloudFront invalidation

echo "🚀 Starting deployment process..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
BUCKET_NAME="${S3_BUCKET_NAME:-shern-security-website-2025}"
AWS_REGION="${AWS_REGION:-us-east-1}"
CLOUDFRONT_DISTRIBUTION_ID="${CLOUDFRONT_DISTRIBUTION_ID:-}"

# Step 1: Build the site
echo -e "${BLUE}📦 Building Astro site...${NC}"
npm run build

if [ ! -d "dist" ]; then
    echo -e "${RED}❌ Build failed: dist/ directory not found${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build complete${NC}"

# Step 2: Sync to S3
echo -e "${BLUE}☁️  Syncing to S3 bucket: ${BUCKET_NAME}...${NC}"
aws s3 sync dist/ "s3://${BUCKET_NAME}" \
    --delete \
    --cache-control "public, max-age=3600" \
    --region "${AWS_REGION}"

echo -e "${GREEN}✅ Files synced to S3${NC}"

# Step 3: Invalidate CloudFront cache (if distribution ID is set)
if [ -n "${CLOUDFRONT_DISTRIBUTION_ID}" ]; then
    echo -e "${BLUE}🔄 Invalidating CloudFront cache...${NC}"
    INVALIDATION_ID=$(aws cloudfront create-invalidation \
        --distribution-id "${CLOUDFRONT_DISTRIBUTION_ID}" \
        --paths "/*" \
        --query 'Invalidation.Id' \
        --output text)
    
    echo -e "${GREEN}✅ CloudFront invalidation created: ${INVALIDATION_ID}${NC}"
    echo -e "${BLUE}⏳ Waiting for invalidation to complete...${NC}"
    
    aws cloudfront wait invalidation-completed \
        --distribution-id "${CLOUDFRONT_DISTRIBUTION_ID}" \
        --id "${INVALIDATION_ID}"
    
    echo -e "${GREEN}✅ CloudFront cache invalidated${NC}"
else
    echo -e "${BLUE}ℹ️  No CloudFront distribution ID set, skipping cache invalidation${NC}"
fi

# Step 4: Get CloudFront URL from Terraform output (if available)
if [ -d "terraform" ] && [ -f "terraform/.terraform/terraform.tfstate" ]; then
    cd terraform
    CLOUDFRONT_URL=$(terraform output -raw cloudfront_url 2>/dev/null || echo "")
    CUSTOM_DOMAIN=$(terraform output -raw custom_domain 2>/dev/null || echo "")
    cd ..
    
    if [ -n "${CLOUDFRONT_URL}" ]; then
        echo -e "${GREEN}🌐 Site deployed to: ${CLOUDFRONT_URL}${NC}"
    fi
    
    if [ -n "${CUSTOM_DOMAIN}" ]; then
        echo -e "${GREEN}🌐 Custom domain: https://${CUSTOM_DOMAIN}${NC}"
    fi
fi

echo -e "${GREEN}🎉 Deployment complete!${NC}"
