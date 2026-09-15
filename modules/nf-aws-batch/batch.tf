resource "aws_batch_compute_environment" "head" {

  compute_environment_name_prefix = "${var.name_prefix}-head-"
  service_role                    = aws_iam_role.batch_service.arn

  lifecycle {
    create_before_destroy = true
  }

  type  = "MANAGED"
  state = "ENABLED"

  compute_resources {
    allocation_strategy = "SPOT_CAPACITY_OPTIMIZED"
    bid_percentage      = 100

    instance_role = aws_iam_instance_profile.batch_instance.arn
    instance_type = ["c5.large"]

    max_vcpus = 6
    min_vcpus = 0

    security_group_ids = local.selected_security_groups
    subnets            = local.selected_subnet_ids

    type = "SPOT"

    ec2_configuration {
      image_type = "ECS_AL2023"
    }

    launch_template {
      launch_template_id = aws_launch_template.nextflow_batch.id
      version            = aws_launch_template.nextflow_batch.latest_version
    }
  }

  tags = merge(var.tags, { pool = "head" })
}

resource "aws_batch_compute_environment" "compute" {

  compute_environment_name_prefix = "${var.name_prefix}-compute-"
  service_role                    = aws_iam_role.batch_service.arn

  lifecycle {
    create_before_destroy = true
  }

  type  = "MANAGED"
  state = "ENABLED"

  compute_resources {
    allocation_strategy = "SPOT_CAPACITY_OPTIMIZED"
    bid_percentage      = 100

    instance_role = aws_iam_instance_profile.batch_instance.arn
    instance_type = ["c5.large"]

    max_vcpus = 6
    min_vcpus = 0

    security_group_ids = local.selected_security_groups
    subnets            = local.selected_subnet_ids

    type = "SPOT"

    ec2_configuration {
      image_type = "ECS_AL2023"
    }

    launch_template {
      launch_template_id = aws_launch_template.nextflow_batch.id
      version            = aws_launch_template.nextflow_batch.latest_version
    }
  }

  tags = merge(var.tags, { pool = "compute" })

}

resource "aws_batch_job_queue" "head" {
  name     = "${var.name_prefix}-head"
  state    = "ENABLED"
  priority = 1

  compute_environment_order {
    order               = 1
    compute_environment = aws_batch_compute_environment.head.arn
  }

  tags = merge(var.tags, { pool = "head" })
}

resource "aws_batch_job_queue" "compute" {
  name     = "${var.name_prefix}-compute"
  state    = "ENABLED"
  priority = 10

  compute_environment_order {
    order               = 1
    compute_environment = aws_batch_compute_environment.compute.arn
  }

  tags = merge(var.tags, { pool = "compute" })
}