resource "azurerm_resource_group" "test" {
  name     = "rg-ai-agent-test"
  location = "eastus2"
}

module "test" {
  source = "../"

  name_prefix        = "aiagent-test"
  location           = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  model_name     = "gpt-4o"
  model_version  = "2024-05-13"
  model_capacity = 30

  search_service_sku     = "basic"
  storage_account_tier   = "Standard"
  storage_replication_type = "LRS"

  enable_monitoring        = true
  enable_private_endpoints = false

  tags = {
    Environment = "test"
    Terraform   = "true"
  }
}
