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
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::nfawsdev-nextflow-work-20260914223108323400000001"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::nfawsdev-nextflow-work-20260914223108323400000001/*"
        ]
      }
    ]
  })
}