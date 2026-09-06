locals {
  resource_group_name = coalesce(var.resource_group_name, "${var.project_name}-${var.environment}-rg")
  common_tags = merge(var.tags, {
    environment = var.environment
    managed_by  = "terraform"
    project     = var.project_name
  })
}

resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags
}

module "nextflow_batch" {
  source = "./modules/nextflow-azure-batch"

  name_prefix            = "${var.project_name}-${var.environment}"
  resource_group_name    = azurerm_resource_group.this.name
  location               = var.location
  storage_container_name = var.storage_container_name
  tags                   = local.common_tags
}