output "static_web_app_url" {
  description = "Default URL of the Static Web App"
  value       = "https://${azurerm_static_web_app.main.default_host_name}"
}

output "static_web_app_id" {
  description = "ID of the Static Web App"
  value       = azurerm_static_web_app.main.id
}

output "static_web_app_api_key" {
  description = "API key for deploying to the Static Web App"
  value       = azurerm_static_web_app.main.api_key
  sensitive   = true
}

output "custom_domain_validation_token" {
  description = "DNS TXT validation token for custom domain"
  value       = var.custom_domain != "" ? azurerm_static_web_app_custom_domain.main[0].validation_token : null
  sensitive   = false
}
