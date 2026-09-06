variable "project_name" {
  description = "Name used to identify resources created by this project."
  type        = string
  default     = "nf-azure"

  validation {
    condition     = can(regex("^[a-z0-9-]{2,40}$", var.project_name))
    error_message = "project_name must contain 2-40 lowercase letters, numbers, or hyphens."
  }
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, test, staging, prod."
  }
}

variable "location" {
  description = "Azure region in which to create resources."
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Optional resource group name. Defaults to <project_name>-<environment>-rg."
  type        = string
  default     = null
  nullable    = true
}

variable "tags" {
  description = "Additional tags to apply to resources."
  type        = map(string)
  default     = {}
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

