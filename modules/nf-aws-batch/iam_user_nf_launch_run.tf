resource "aws_iam_user" "nf_launch_run" {
  name = "nf-launch-run"
  path = "/"

  tags = var.tags
}

data "aws_iam_policy_document" "nf_launch_run_bucket_discovery" {
  statement {
    sid       = "ListVisibleBuckets"
    effect    = "Allow"
    actions   = [
      "s3:ListAllMyBuckets"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "nf_launch_run" {
  statement {
    sid    = "ListWorkBucket"
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
    ]
    resources = [aws_s3_bucket.work.arn]

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
    resources = ["${aws_s3_bucket.work.arn}/${var.work_prefix}/*"]
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
    resources = [aws_iam_role.batch_instance.arn]
  }
}

resource "aws_iam_user_policy" "nf_launch_run" {
  name   = "nf-launch-run"
  user   = aws_iam_user.nf_launch_run.name
  policy = data.aws_iam_policy_document.nf_launch_run.json
}

resource "aws_iam_user_policy" "nf_launch_run_bucket_discovery" {
  name   = "nf-launch-run-bucket-discovery"
  user   = aws_iam_user.nf_launch_run.name
  policy = data.aws_iam_policy_document.nf_launch_run_bucket_discovery.json
}