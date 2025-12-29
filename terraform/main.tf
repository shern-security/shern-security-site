terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 1.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azapi" {
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Azure Static Web App (Free tier)
resource "azurerm_static_web_app" "main" {
  name                = var.static_site_name
  resource_group_name = azurerm_resource_group.main.name
  location            = var.static_site_location
  sku_tier            = "Free"
  sku_size            = "Free"

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Custom Domain (optional)
resource "azurerm_static_web_app_custom_domain" "main" {
  count               = var.custom_domain != "" ? 1 : 0
  static_web_app_id   = azurerm_static_web_app.main.id
  domain_name         = var.custom_domain
  validation_type     = "dns-txt-token"
}
