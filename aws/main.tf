locals {
  common_tags = merge(var.tags, {
    environment = var.environment
    managed_by  = "terraform"
    project     = var.project_name
  })
}

module "nextflow_batch" {
  source = "../modules/nf-aws-batch"

  name_prefix          = "${var.project_name}-${var.environment}"
  bucket_name          = var.bucket_name
  work_prefix          = var.work_prefix
  nextflow_role_arn    = var.nextflow_role_arn
  force_destroy_bucket = var.force_destroy_bucket
  vpc_id               = var.vpc_id
  vpc_cidr             = var.vpc_cidr
  subnet_ids           = var.subnet_ids
  security_group_ids   = var.security_group_ids
  tags                 = local.common_tags
}