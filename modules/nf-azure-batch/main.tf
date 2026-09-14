locals {
  normalized_prefix    = replace(var.name_prefix, "-", "")
  batch_account_name   = "${local.normalized_prefix}batch"
  storage_account_name = "${local.normalized_prefix}st"
}

resource "azurerm_batch_account" "this" {
  name                         = local.batch_account_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  pool_allocation_mode         = "BatchService"
  allowed_authentication_modes = ["AAD"]
  tags                         = var.tags
}

resource "azurerm_storage_account" "this" {
  name                            = local.storage_account_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_kind                    = "StorageV2"
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
  tags                            = var.tags
}

resource "azurerm_storage_container" "work" {
  name                  = var.storage_container_name
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}

data "azurerm_client_config" "current" {}

resource "azuread_application" "nextflow" {
  display_name = var.entra_application_name
  owners       = [data.azurerm_client_config.current.object_id]
}

resource "azuread_service_principal" "nextflow" {
  client_id                    = azuread_application.nextflow.client_id
  app_role_assignment_required = false
  owners                       = [data.azurerm_client_config.current.object_id]
}

resource "azuread_service_principal_password" "nextflow" {
  service_principal_id = azuread_service_principal.nextflow.id
  display_name         = "nextflow"
  end_date_relative    = var.service_principal_secret_expiry
}

resource "azurerm_role_assignment" "batch_data" {
  scope                = azurerm_batch_account.this.id
  role_definition_name = "Azure Batch Data Contributor"
  principal_id         = azuread_service_principal.nextflow.object_id
}

resource "azurerm_role_assignment" "storage_blob_data" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.nextflow.object_id
}

