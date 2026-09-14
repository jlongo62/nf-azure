variable "name_prefix" {
  description = "Lowercase prefix used for AWS resource names."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{2,29}$", var.name_prefix))
    error_message = "name_prefix must contain 3-30 lowercase letters, numbers, or hyphens and start with a letter or number."
  }
}

variable "bucket_name" {
  description = "Optional globally unique S3 bucket name for Nextflow work data."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.bucket_name == null || can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name must be 3-63 characters and use lowercase letters, numbers, periods, or hyphens."
  }
}

variable "work_prefix" {
  description = "Object prefix reserved for Nextflow work data."
  type        = string
  default     = "nextflow"

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9/_-]{0,127}$", var.work_prefix))
    error_message = "work_prefix must be 1-128 characters and may contain letters, numbers, slashes, hyphens, or underscores."
  }
}

variable "nextflow_role_arn" {
  description = "Optional existing IAM role ARN used by the external Nextflow service to receive the S3 and AWS Batch policy."
  type        = string
  default     = null
  nullable    = true
}

variable "force_destroy_bucket" {
  description = "Allow Terraform to delete a non-empty work bucket."
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "Optional existing VPC for the AWS Batch compute environments. If omitted, the module creates a dedicated VPC."
  type        = string
  default     = null
  nullable    = true
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC created when vpc_id is omitted."
  type        = string
  default     = "10.42.0.0/16"
}

variable "subnet_ids" {
  description = "Optional existing subnet IDs. If omitted with vpc_id, the module creates two public subnets."
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "Optional existing security groups. If omitted with vpc_id, the module creates a Batch security group."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags for AWS resources."
  type        = map(string)
  default     = {}
}