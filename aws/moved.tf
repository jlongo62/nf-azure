moved {
  from = aws_iam_user.nf_launch_run
  to   = module.nextflow_batch.aws_iam_user.nf_launch_run
}

moved {
  from = aws_iam_user_policy.nf_launch_run
  to   = module.nextflow_batch.aws_iam_user_policy.nf_launch_run
}

moved {
  from = aws_iam_user_policy.nf_launch_run_bucket_discovery
  to   = module.nextflow_batch.aws_iam_user_policy.nf_launch_run_bucket_discovery
}