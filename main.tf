data "azurerm_client_config" "current" {}

locals {
  openai_name        = "${var.name_prefix}-openai"
  search_name        = "${var.name_prefix}-search"
  storage_name       = replace(lower("${var.name_prefix}storage"), "-", "")
  keyvault_name      = "${var.name_prefix}-kv"
  identity_name      = "${var.name_prefix}-identity"
  appinsights_name   = "${var.name_prefix}-appinsights"
  log_analytics_name = "${var.name_prefix}-logs"
}

# ------------------------------------------------------------------------------
# User-Assigned Managed Identity
# ------------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "this" {
  name                = local.identity_name
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = var.tags
}

# ------------------------------------------------------------------------------
# Azure OpenAI (Cognitive Account)
# ------------------------------------------------------------------------------
resource "azurerm_cognitive_account" "openai" {
  name                  = local.openai_name
  resource_group_name   = var.resource_group_name
  location              = var.location
  kind                  = "OpenAI"
  sku_name              = var.openai_sku
  custom_subdomain_name = local.openai_name

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.this.id]
  }

  network_acls {
    default_action = length(var.allowed_ip_ranges) > 0 ? "Deny" : "Allow"

    dynamic "ip_rules" {
      for_each = var.allowed_ip_ranges
      content {
        ip_range = ip_rules.value
      }
    }
  }

  tags = var.tags
}

# ------------------------------------------------------------------------------
# Model Deployment (GPT-4o)
# ------------------------------------------------------------------------------
resource "azurerm_cognitive_deployment" "model" {
  name                 = var.model_name
  cognitive_account_id = azurerm_cognitive_account.openai.id

  model {
    format  = "OpenAI"
    name    = var.model_name
    version = var.model_version
  }

  sku {
    name     = "Standard"
    capacity = var.model_capacity
  }
}

# ------------------------------------------------------------------------------
# Azure AI Search Service
# ------------------------------------------------------------------------------
resource "azurerm_search_service" "this" {
  name                = local.search_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.search_service_sku

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# ------------------------------------------------------------------------------
# Storage Account (file uploads, code interpreter)
# ------------------------------------------------------------------------------
resource "azurerm_storage_account" "this" {
  name                     = local.storage_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_replication_type
  min_tls_version          = "TLS1_2"

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 7
    }

    container_delete_retention_policy {
      days = 7
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "azurerm_storage_container" "file_uploads" {
  name                  = "file-uploads"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "code_interpreter" {
  name                  = "code-interpreter"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

# ------------------------------------------------------------------------------
# Key Vault
# ------------------------------------------------------------------------------
resource "azurerm_key_vault" "this" {
  name                       = local.keyvault_name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = var.key_vault_sku
  purge_protection_enabled   = var.key_vault_purge_protection
  soft_delete_retention_days = var.key_vault_soft_delete_retention

  enable_rbac_authorization = true

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  tags = var.tags
}

# Store OpenAI API key in Key Vault
resource "azurerm_key_vault_secret" "openai_key" {
  name         = "openai-api-key"
  value        = azurerm_cognitive_account.openai.primary_access_key
  key_vault_id = azurerm_key_vault.this.id

  depends_on = [azurerm_role_assignment.deployer_keyvault_admin]
}

# ------------------------------------------------------------------------------
# Log Analytics Workspace
# ------------------------------------------------------------------------------
resource "azurerm_log_analytics_workspace" "this" {
  name                = local.log_analytics_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = var.log_analytics_retention_days

  tags = var.tags
}

# ------------------------------------------------------------------------------
# Application Insights
# ------------------------------------------------------------------------------
resource "azurerm_application_insights" "this" {
  count = var.enable_monitoring ? 1 : 0

  name                = local.appinsights_name
  resource_group_name = var.resource_group_name
  location            = var.location
  workspace_id        = azurerm_log_analytics_workspace.this.id
  application_type    = "other"

  tags = var.tags
}

# ------------------------------------------------------------------------------
# Diagnostic Settings
# ------------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "openai" {
  name                       = "${local.openai_name}-diagnostics"
  target_resource_id         = azurerm_cognitive_account.openai.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  enabled_log {
    category = "Audit"
  }

  enabled_log {
    category = "RequestResponse"
  }

  metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "search" {
  name                       = "${local.search_name}-diagnostics"
  target_resource_id         = azurerm_search_service.this.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  enabled_log {
    category = "OperationLogs"
  }

  metric {
    category = "AllMetrics"
  }
}

# ------------------------------------------------------------------------------
# RBAC Role Assignments
# ------------------------------------------------------------------------------

# Managed identity gets Cognitive Services OpenAI User on the OpenAI account
resource "azurerm_role_assignment" "identity_openai_user" {
  scope                = azurerm_cognitive_account.openai.id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}

# Managed identity gets Storage Blob Data Contributor on the storage account
resource "azurerm_role_assignment" "identity_storage_blob" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}

# Managed identity gets Search Index Data Contributor on the search service
resource "azurerm_role_assignment" "identity_search_contributor" {
  scope                = azurerm_search_service.this.id
  role_definition_name = "Search Index Data Contributor"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}

# Managed identity gets Key Vault Secrets User
resource "azurerm_role_assignment" "identity_keyvault_reader" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}

# OpenAI system identity gets Search Index Data Reader for grounding
resource "azurerm_role_assignment" "openai_search_reader" {
  scope                = azurerm_search_service.this.id
  role_definition_name = "Search Index Data Reader"
  principal_id         = azurerm_cognitive_account.openai.identity[0].principal_id
}

# OpenAI system identity gets Storage Blob Data Reader for file access
resource "azurerm_role_assignment" "openai_storage_reader" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_cognitive_account.openai.identity[0].principal_id
}

# Deployer gets Key Vault Administrator to write secrets
resource "azurerm_role_assignment" "deployer_keyvault_admin" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

# ------------------------------------------------------------------------------
# Private Endpoints (optional)
# ------------------------------------------------------------------------------
resource "azurerm_private_endpoint" "openai" {
  count = var.enable_private_endpoints ? 1 : 0

  name                = "${local.openai_name}-pe"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${local.openai_name}-psc"
    private_connection_resource_id = azurerm_cognitive_account.openai.id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "search" {
  count = var.enable_private_endpoints ? 1 : 0

  name                = "${local.search_name}-pe"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${local.search_name}-psc"
    private_connection_resource_id = azurerm_search_service.this.id
    is_manual_connection           = false
    subresource_names              = ["searchService"]
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "storage" {
  count = var.enable_private_endpoints ? 1 : 0

  name                = "${local.storage_name}-pe"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${local.storage_name}-psc"
    private_connection_resource_id = azurerm_storage_account.this.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "keyvault" {
  count = var.enable_private_endpoints ? 1 : 0

  name                = "${local.keyvault_name}-pe"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${local.keyvault_name}-psc"
    private_connection_resource_id = azurerm_key_vault.this.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  tags = var.tags
}
