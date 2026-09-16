output "work_bucket_id" {
  description = "ID of the private S3 bucket used for Nextflow work data."
  value       = aws_s3_bucket.work.id
}

output "work_bucket_name" {
  description = "Name of the private S3 bucket used for Nextflow work data."
  value       = aws_s3_bucket.work.bucket
}

output "work_bucket_arn" {
  description = "ARN of the private S3 bucket used for Nextflow work data."
  value       = aws_s3_bucket.work.arn
}

output "work_prefix" {
  description = "Object prefix reserved for Nextflow work data."
  value       = var.work_prefix
}

output "work_uri" {
  description = "S3 URI to use as the Nextflow work directory."
  value       = "s3://${aws_s3_bucket.work.bucket}/${var.work_prefix}"
}

output "batch_instance_role_arn" {
  description = "ARN of the IAM role used by AWS Batch compute instances."
  value       = aws_iam_role.batch_instance.arn
}

output "head_queue_name" {
  description = "AWS Batch job queue for head jobs."
  value       = aws_batch_job_queue.head.name
}

output "compute_queue_name" {
  description = "AWS Batch job queue for compute jobs."
  value       = aws_batch_job_queue.compute.name
}

output "head_compute_environment_name" {
  description = "AWS Batch head compute environment name."
  value       = aws_batch_compute_environment.head.compute_environment_name
}

output "compute_compute_environment_name" {
  description = "AWS Batch compute compute environment name."
  value       = aws_batch_compute_environment.compute.compute_environment_name
}

output "aws_batch_role_nextflow_job" {
  description = "ARN of the AWS Batch job role."
  value       = aws_iam_role.nextflow_job
}