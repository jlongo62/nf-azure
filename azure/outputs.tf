output "resource_group_id" {
  description = "ID of the Azure resource group."
  value       = azurerm_resource_group.this.id
}

output "resource_group_name" {
  description = "Name of the Azure resource group."
  value       = azurerm_resource_group.this.name
}

output "resource_group_location" {
  description = "Azure region of the resource group."
  value       = azurerm_resource_group.this.location
}

output "batch_account_name" {
  description = "Name of the Nextflow Azure Batch account."
  value       = module.nextflow_batch.batch_account_name
}

output "batch_account_endpoint" {
  description = "Endpoint of the Nextflow Azure Batch account."
  value       = module.nextflow_batch.batch_account_endpoint
}

output "storage_account_name" {
  description = "Azure Storage account used by Nextflow."
  value       = module.nextflow_batch.storage_account_name
}

output "storage_container_name" {
  description = "Private Blob container used by Nextflow."
  value       = module.nextflow_batch.storage_container_name
}

output "entra_tenant_id" {
  description = "Microsoft Entra tenant ID for the Nextflow service principal."
  value       = module.nextflow_batch.entra_tenant_id
}

output "entra_client_id" {
  description = "Microsoft Entra client ID for Nextflow."
  value       = module.nextflow_batch.entra_client_id
}

output "entra_client_secret" {
  description = "Microsoft Entra client secret for Nextflow. Store it securely."
  value       = module.nextflow_batch.entra_client_secret
  sensitive   = true
}