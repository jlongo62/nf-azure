locals {
  generated_bucket_name    = "${replace(var.name_prefix, "-", "")}-nextflow-work"
  selected_vpc_id          = var.vpc_id == null ? aws_vpc.batch[0].id : var.vpc_id
  selected_subnet_ids      = length(var.subnet_ids) > 0 ? var.subnet_ids : (var.vpc_id == null ? aws_subnet.batch[*].id : data.aws_subnets.existing[0].ids)
  selected_security_groups = length(var.security_group_ids) > 0 ? var.security_group_ids : (var.vpc_id == null ? [aws_security_group.batch[0].id] : [data.aws_security_group.existing[0].id])
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "batch" {
  count                = var.vpc_id == null ? 1 : 0
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = merge(var.tags, { Name = "${var.name_prefix}-batch" })
}

resource "aws_internet_gateway" "batch" {
  count  = var.vpc_id == null ? 1 : 0
  vpc_id = aws_vpc.batch[0].id
  tags   = merge(var.tags, { Name = "${var.name_prefix}-batch" })
}

resource "aws_subnet" "batch" {
  count                   = var.vpc_id == null ? 2 : 0
  vpc_id                  = aws_vpc.batch[0].id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  map_public_ip_on_launch = true
  tags                    = merge(var.tags, { Name = "${var.name_prefix}-batch-${count.index + 1}" })
}

resource "aws_route_table" "batch" {
  count  = var.vpc_id == null ? 1 : 0
  vpc_id = aws_vpc.batch[0].id
  tags   = merge(var.tags, { Name = "${var.name_prefix}-batch" })

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.batch[0].id
  }
}

resource "aws_route_table_association" "batch" {
  count          = var.vpc_id == null ? 2 : 0
  route_table_id = aws_route_table.batch[0].id
  subnet_id      = aws_subnet.batch[count.index].id
}

resource "aws_security_group" "batch" {
  count       = var.vpc_id == null ? 1 : 0
  name        = "${var.name_prefix}-batch"
  description = "Outbound access for Nextflow AWS Batch instances."
  vpc_id      = aws_vpc.batch[0].id

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-batch" })
}

data "aws_subnets" "existing" {
  count = var.vpc_id != null && length(var.subnet_ids) == 0 ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_security_group" "existing" {
  count  = var.vpc_id != null && length(var.security_group_ids) == 0 ? 1 : 0
  vpc_id = var.vpc_id
  name   = "default"
}

data "aws_iam_policy_document" "batch_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["batch.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "batch_service" {
  name               = "${var.name_prefix}-batch-service"
  assume_role_policy = data.aws_iam_policy_document.batch_assume_role.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "batch_service" {
  role       = aws_iam_role.batch_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

resource "aws_iam_role" "batch_instance" {
  name               = "${var.name_prefix}-batch-instance"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "batch_instance" {
  role       = aws_iam_role.batch_instance.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "batch_instance" {
  name = "${var.name_prefix}-batch-instance"
  role = aws_iam_role.batch_instance.name
  tags = var.tags
}

resource "aws_s3_bucket" "work" {
  bucket        = var.bucket_name
  bucket_prefix = var.bucket_name == null ? "${local.generated_bucket_name}-" : null
  force_destroy = var.force_destroy_bucket

  tags = var.tags
}

resource "aws_s3_bucket_ownership_controls" "work" {
  bucket = aws_s3_bucket.work.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "work" {
  bucket = aws_s3_bucket.work.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "work" {
  bucket = aws_s3_bucket.work.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

