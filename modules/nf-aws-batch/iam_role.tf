resource "aws_iam_role" "nextflow_job" {
  name = "${var.name_prefix}-nextflow-job"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "nextflow_job_s3" {
  role = aws_iam_role.nextflow_job.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads"
        ]
        Resource = [aws_s3_bucket.work.arn]
        Condition = {
          StringLike = {
            "s3:prefix" = [var.work_prefix, "${var.work_prefix}/*"]
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetObject",
          "s3:ListMultipartUploadParts",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = ["${aws_s3_bucket.work.arn}/${var.work_prefix}/*"]
      }
    ]
  })
}