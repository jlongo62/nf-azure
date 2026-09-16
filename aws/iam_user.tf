resource "aws_iam_user" "nfcc_launch_run" {
  name = "nfcc-launch-run"
  path = "/"

  tags = local.common_tags
}

data "aws_iam_policy_document" "nfcc_launch_run" {
  statement {
    sid    = "ListWorkBucket"
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
    ]
    resources = [module.nextflow_batch.work_bucket_arn]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = [var.work_prefix, "${var.work_prefix}/*"]
    }
  }

  statement {
    sid    = "ReadWriteWorkObjects"
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
    ]
    resources = ["${module.nextflow_batch.work_bucket_arn}/${var.work_prefix}/*"]
  }

  statement {
    sid    = "SubmitBatchJobs"
    effect = "Allow"
    actions = [
      "batch:CancelJob",
      "batch:DescribeJobDefinitions",
      "batch:DescribeJobs",
      "batch:DescribeComputeEnvironments",
      "batch:DescribeJobQueues",
      "batch:ListJobs",
      "batch:RegisterJobDefinition",
      "batch:SubmitJob",
      "batch:TerminateJob",
    ]
    resources = ["*"]
  }

  statement {
    sid       = "PassBatchInstanceRole"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [module.nextflow_batch.batch_instance_role_arn]
  }
}

resource "aws_iam_user_policy" "nfcc_launch_run" {
  name   = "nfcc-launch-run"
  user   = aws_iam_user.nfcc_launch_run.name
  policy = data.aws_iam_policy_document.nfcc_launch_run.json
}

output "nfcc_launch_run_user_name" {
  description = "IAM user intended for nf-command-center workflow launches."
  value       = aws_iam_user.nfcc_launch_run.name
}

output "nfcc_launch_run_user_arn" {
  description = "ARN of the nf-command-center workflow launch IAM user."
  value       = aws_iam_user.nfcc_launch_run.arn
}
