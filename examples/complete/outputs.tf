output "openai_endpoint" {
  description = "The endpoint URL for the Azure OpenAI service"
  value       = module.ai_agent_service.openai_endpoint
}

output "openai_id" {
  description = "The resource ID of the Azure OpenAI Cognitive Account"
  value       = module.ai_agent_service.openai_id
}

output "search_service_id" {
  description = "The resource ID of the Azure AI Search service"
  value       = module.ai_agent_service.search_service_id
}

output "search_service_endpoint" {
  description = "The endpoint URL of the Azure AI Search service"
  value       = module.ai_agent_service.search_service_endpoint
}

output "storage_account_id" {
  description = "The resource ID of the storage account"
  value       = module.ai_agent_service.storage_account_id
}

output "key_vault_id" {
  description = "The resource ID of the Key Vault"
  value       = module.ai_agent_service.key_vault_id
}

output "identity_id" {
  description = "The resource ID of the user-assigned managed identity"
  value       = module.ai_agent_service.identity_id
}

output "model_deployment_name" {
  description = "The name of the deployed model"
  value       = module.ai_agent_service.model_deployment_name
}

output "log_analytics_workspace_id" {
  description = "The resource ID of the Log Analytics workspace"
  value       = module.ai_agent_service.log_analytics_workspace_id
}
