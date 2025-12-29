variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
  default     = "shern-security-rg"
}

variable "location" {
  description = "Azure region for the resource group"
  type        = string
  default     = "eastus"
}

variable "static_site_location" {
  description = "Azure region for Static Web App (limited regions)"
  type        = string
  default     = "eastus2"
}

variable "static_site_name" {
  description = "Name of the Azure Static Web App"
  type        = string
  default     = "shern-security"
}

variable "custom_domain" {
  description = "Custom domain name for the website"
  type        = string
  default     = "shernsecurity.com"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}
