provider "azurerm" {
  features {}

  resource_provider_registrations = "all"
  storage_use_azuread             = true
}

provider "azuread" {}