resource "aws_iam_user" "nfcc_datalink" {
  name = "nfcc-datalink"
  path = "/"

  tags = var.tags
}

data "aws_iam_policy_document" "nfcc_datalink" {
  statement {
    sid    = "ListWorkBucket"
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]
    resources = [aws_s3_bucket.work.arn]
  }

  statement {
    sid    = "DataLinkPermissions"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = ["${aws_s3_bucket.work.arn}/*"]
  }

  statement {
    sid    = "ListWorkBuckets"
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]
    resources = ["${aws_s3_bucket.work.arn}"]
  }   
  statement {
    sid    = "ListAllBuckets"
    effect = "Allow"
    actions = [
      "s3:ListAllMyBuckets",
    ]
    resources = ["*"]
  }     
}

resource "aws_iam_user_policy" "nfcc_datalink" {
  name   = "nfcc-datalink"
  user   = aws_iam_user.nfcc_datalink.name
  policy = data.aws_iam_policy_document.nfcc_datalink.json
}