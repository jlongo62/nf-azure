variable "name_prefix" {
  description = "Lowercase prefix used for the globally unique Azure Batch account name."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{3,19}$", var.name_prefix))
    error_message = "name_prefix must contain 3-19 lowercase letters, numbers, or hyphens."
  }
}

variable "resource_group_name" {
  description = "Resource group in which to create the Batch account and storage account."
  type        = string
}

variable "location" {
  description = "Azure region for the Batch account and storage account."
  type        = string
}

variable "storage_container_name" {
  description = "Private Blob container used by Nextflow for scratch files and outputs."
  type        = string
  default     = "scratch"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.storage_container_name))
    error_message = "storage_container_name must contain 3-63 lowercase letters, numbers, or hyphens and start/end with a letter or number."
  }
}

variable "tags" {
  description = "Additional tags for the Batch and storage resources."
  type        = map(string)
  default     = {}
}

variable "entra_application_name" {
  description = "Display name for the Entra application and service principal used by Nextflow."
  type        = string
  default     = "nf-azure-nextflow"
}

variable "service_principal_secret_expiry" {
  description = "Lifetime of the Nextflow service principal secret."
  type        = string
  default     = "8760h"
}