output "openai_endpoint" {
  description = "The endpoint URL for the Azure OpenAI service."
  value       = azurerm_cognitive_account.openai.endpoint
}

output "openai_id" {
  description = "The resource ID of the Azure OpenAI Cognitive Account."
  value       = azurerm_cognitive_account.openai.id
}

output "search_service_id" {
  description = "The resource ID of the Azure AI Search service."
  value       = azurerm_search_service.this.id
}

output "search_service_endpoint" {
  description = "The endpoint URL of the Azure AI Search service."
  value       = "https://${azurerm_search_service.this.name}.search.windows.net"
}

output "storage_account_id" {
  description = "The resource ID of the storage account."
  value       = azurerm_storage_account.this.id
}

output "key_vault_id" {
  description = "The resource ID of the Key Vault."
  value       = azurerm_key_vault.this.id
}

output "identity_id" {
  description = "The resource ID of the user-assigned managed identity."
  value       = azurerm_user_assigned_identity.this.id
}

output "application_insights_id" {
  description = "The resource ID of Application Insights."
  value       = var.enable_monitoring ? azurerm_application_insights.this[0].id : null
}

output "openai_principal_id" {
  description = "The system-assigned principal ID of the OpenAI Cognitive Account."
  value       = azurerm_cognitive_account.openai.identity[0].principal_id
}

output "identity_principal_id" {
  description = "The principal ID of the user-assigned managed identity."
  value       = azurerm_user_assigned_identity.this.principal_id
}

output "identity_client_id" {
  description = "The client ID of the user-assigned managed identity."
  value       = azurerm_user_assigned_identity.this.client_id
}

output "log_analytics_workspace_id" {
  description = "The resource ID of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.this.id
}

output "storage_account_name" {
  description = "The name of the storage account."
  value       = azurerm_storage_account.this.name
}

output "key_vault_uri" {
  description = "The URI of the Key Vault."
  value       = azurerm_key_vault.this.vault_uri
}

output "model_deployment_name" {
  description = "The name of the deployed model."
  value       = azurerm_cognitive_deployment.model.name
}

output "application_insights_connection_string" {
  description = "The connection string for Application Insights."
  value       = var.enable_monitoring ? azurerm_application_insights.this[0].connection_string : null
  sensitive   = true
}
