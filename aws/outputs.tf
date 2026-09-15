output "work_bucket_name" {
  description = "S3 bucket used for Nextflow work data."
  value       = module.nextflow_batch.work_bucket_name
}

output "work_bucket_arn" {
  description = "ARN of the S3 bucket used for Nextflow work data."
  value       = module.nextflow_batch.work_bucket_arn
}

output "work_uri" {
  description = "S3 URI to use as the Nextflow work directory."
  value       = module.nextflow_batch.work_uri
}

output "nextflow_policy_arn" {
  description = "ARN of the IAM policy containing Nextflow permissions."
  value       = module.nextflow_batch.nextflow_policy_arn
}

output "head_queue_name" {
  description = "AWS Batch job queue for head jobs."
  value       = module.nextflow_batch.head_queue_name
}

output "compute_queue_name" {
  description = "AWS Batch job queue for compute jobs."
  value       = module.nextflow_batch.compute_queue_name
}

output "aws_batch_jobRole_arn" {
  description = "ARN of the AWS Batch job role."
  value       = module.nextflow_batch.aws_batch_role_nextflow_job.arn
}
