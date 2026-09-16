variable "project_name" {
  description = "Name used to identify resources created by this project."
  type        = string
  default     = "nf-aws"

  validation {
    condition     = can(regex("^[a-z0-9-]{2,24}$", var.project_name))
    error_message = "project_name must contain 2-24 lowercase letters, numbers, or hyphens."
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

variable "region" {
  description = "AWS region in which to create resources."
  type        = string
  default     = "us-east-2"
}

variable "bucket_name" {
  description = "Optional globally unique S3 bucket name."
  type        = string
  default     = null
  nullable    = true
}

variable "work_prefix" {
  description = "Object prefix reserved for Nextflow work data."
  type        = string
  default     = "nextflow"
}

variable "force_destroy_bucket" {
  description = "Allow Terraform to delete a non-empty work bucket."
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "Optional existing VPC for AWS Batch. If omitted, the module creates a dedicated VPC."
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
  description = "Additional tags to apply to AWS resources."
  type        = map(string)
  default     = {}
}