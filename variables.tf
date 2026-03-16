variable "name_prefix" {
  description = "Prefix used for naming all resources."
  type        = string
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group to deploy into."
  type        = string
}

variable "openai_sku" {
  description = "SKU name for the Azure OpenAI Cognitive Account."
  type        = string
  default     = "S0"
}

variable "model_name" {
  description = "Name of the model to deploy (e.g., gpt-4o, gpt-4, gpt-35-turbo)."
  type        = string
  default     = "gpt-4o"
}

variable "model_version" {
  description = "Version of the model to deploy."
  type        = string
  default     = "2024-05-13"
}

variable "model_capacity" {
  description = "Token-per-minute capacity in thousands for the model deployment."
  type        = number
  default     = 30
}

variable "search_service_sku" {
  description = "SKU for Azure AI Search service (free, basic, standard, standard2, standard3)."
  type        = string
  default     = "basic"

  validation {
    condition     = contains(["free", "basic", "standard", "standard2", "standard3", "storage_optimized_l1", "storage_optimized_l2"], var.search_service_sku)
    error_message = "search_service_sku must be a valid Azure AI Search SKU."
  }
}

variable "storage_account_tier" {
  description = "Performance tier of the storage account (Standard or Premium)."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "storage_account_tier must be Standard or Premium."
  }
}

variable "enable_private_endpoints" {
  description = "Enable private endpoints for OpenAI, Search, and Storage resources."
  type        = bool
  default     = false
}

variable "enable_monitoring" {
  description = "Enable Application Insights and Log Analytics monitoring."
  type        = bool
  default     = true
}

variable "allowed_ip_ranges" {
  description = "List of IP CIDR ranges allowed to access the OpenAI service."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "key_vault_sku" {
  description = "SKU for the Key Vault (standard or premium)."
  type        = string
  default     = "standard"
}

variable "key_vault_purge_protection" {
  description = "Enable purge protection on the Key Vault."
  type        = bool
  default     = true
}

variable "key_vault_soft_delete_retention" {
  description = "Number of days to retain soft-deleted Key Vault items."
  type        = number
  default     = 90
}

variable "storage_replication_type" {
  description = "Replication type for the storage account (LRS, GRS, RAGRS, ZRS)."
  type        = string
  default     = "LRS"
}

variable "log_analytics_retention_days" {
  description = "Number of days to retain logs in Log Analytics."
  type        = number
  default     = 30
}

variable "virtual_network_id" {
  description = "ID of the virtual network for private endpoints."
  type        = string
  default     = ""
}

variable "private_endpoint_subnet_id" {
  description = "ID of the subnet for private endpoints."
  type        = string
  default     = ""
}
