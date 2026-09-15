provider "azurerm" {
  features {}

  resource_provider_registrations = "none"
  resource_providers_to_register  = [
    "Microsoft.Batch",
    "Microsoft.Storage",
    "Microsoft.Authorization",
  ]
  storage_use_azuread = true
}

provider "azuread" {}