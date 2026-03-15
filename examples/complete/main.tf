###############################################################################
# Complete Example - Azure AI Agent Service
#
# This example deploys a fully configured AI Agent Service with:
# - Azure OpenAI with GPT-4o model deployment
# - Azure AI Search (basic tier)
# - Storage Account with versioning and soft delete
# - Key Vault with RBAC authorization
# - Log Analytics and Application Insights monitoring
# - Private endpoints for all services
###############################################################################

resource "azurerm_resource_group" "example" {
  name     = "rg-ai-agent-complete"
  location = "eastus2"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-ai-agent-complete"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "endpoints" {
  name                 = "snet-private-endpoints"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

module "ai_agent_service" {
  source = "../../"

  name_prefix         = "aiagent-prod"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  # OpenAI Configuration
  openai_sku    = "S0"
  model_name    = "gpt-4o"
  model_version = "2024-05-13"
  model_capacity = 50

  # AI Search Configuration
  search_service_sku = "basic"

  # Storage Configuration
  storage_account_tier     = "Standard"
  storage_replication_type = "GRS"

  # Key Vault Configuration
  key_vault_sku                   = "standard"
  key_vault_purge_protection      = true
  key_vault_soft_delete_retention = 90

  # Monitoring Configuration
  enable_monitoring            = true
  log_analytics_retention_days = 90

  # Network Configuration - Private Endpoints
  enable_private_endpoints   = true
  virtual_network_id         = azurerm_virtual_network.example.id
  private_endpoint_subnet_id = azurerm_subnet.endpoints.id

  # IP Restrictions
  allowed_ip_ranges = ["203.0.113.0/24"]

  tags = {
    Environment = "production"
    Project     = "ai-agent-service"
    ManagedBy   = "terraform"
    CostCenter  = "ai-operations"
  }
}
