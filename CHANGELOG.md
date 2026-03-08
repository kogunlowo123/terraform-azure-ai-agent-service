# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-12-01

### Added

- Initial release of the terraform-azure-ai-agent-service module.
- Azure OpenAI Cognitive Account with configurable SKU and network ACLs.
- GPT-4o model deployment with configurable capacity.
- Azure AI Search service for grounding and retrieval.
- Storage account with blob versioning and containers for file uploads and code interpreter.
- Key Vault with RBAC authorization and automatic API key storage.
- User-assigned managed identity with least-privilege RBAC assignments.
- Log Analytics workspace for centralized logging.
- Application Insights for monitoring (optional).
- Diagnostic settings for OpenAI and Search services.
- Private endpoints for OpenAI, Search, Storage, and Key Vault (optional).
- Comprehensive RBAC role assignments across all services.

## [0.1.0] - 2024-10-15

### Added

- Pre-release module scaffolding.
- Basic Azure OpenAI and Search service resources.
