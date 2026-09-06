output "batch_account_name" {
  description = "Name of the Azure Batch account."
  value       = azurerm_batch_account.this.name
}

output "batch_account_endpoint" {
  description = "Endpoint of the Azure Batch account."
  value       = azurerm_batch_account.this.account_endpoint
}

output "storage_account_name" {
  description = "Name of the Azure Storage account used by Nextflow."
  value       = azurerm_storage_account.this.name
}

output "storage_container_name" {
  description = "Private Blob container used by Nextflow."
  value       = azurerm_storage_container.work.name
}

output "entra_tenant_id" {
  description = "Microsoft Entra tenant ID for the Nextflow service principal."
  value       = data.azurerm_client_config.current.tenant_id
}

output "entra_client_id" {
  description = "Microsoft Entra application/client ID for Nextflow."
  value       = azuread_application.nextflow.client_id
}

output "entra_client_secret" {
  description = "Microsoft Entra client secret for Nextflow. Store it securely."
  value       = azuread_service_principal_password.nextflow.value
  sensitive   = true
}