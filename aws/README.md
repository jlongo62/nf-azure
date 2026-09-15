# nf-aws

Terraform baseline for the AWS resources needed by a Nextflow AWS Batch integration. It creates a private, encrypted S3 work bucket, IAM roles, and separate head and compute AWS Batch pools.

Both pools use `c5.large` Spot instances, scale from zero, and have a maximum of three instances (`max_vcpus = 6`). `c5.large` is an x86_64 instance type accepted by AWS Batch in `us-east-2`. When no VPC, subnet, or security group IDs are supplied, the module creates a dedicated VPC with two public subnets, an internet gateway, routing, and a Batch security group. Supply an existing `nextflow_role_arn` to attach the generated policy to the external service that starts workflows, or attach `nextflow_policy_arn` to that role through your existing IAM workflow.

## Prerequisites

- Terraform 1.7 or newer
- AWS credentials available through the standard AWS provider credential chain
- Permission to create S3 buckets, IAM roles/policies, VPC networking, and AWS Batch environments/queues

Do not put access keys or secrets in Terraform files. Use an AWS profile, environment variables, workload identity, or an instance/task role. External services communicate with AWS Batch and S3 over their authenticated regional HTTPS APIs; the S3 bucket remains private and does not need public access.

## Deploy

```sh
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars for the target account and region.
terraform init
terraform fmt -check
terraform validate
terraform plan -out=nf-aws.tfplan
terraform apply nf-aws.tfplan
```

Review every plan before applying it. To remove the resources later, run `terraform destroy` after reviewing the destroy plan. The default `force_destroy_bucket = false` prevents Terraform from deleting a non-empty work bucket.

## Configure Nextflow

Use the outputs after deployment:

```sh
terraform output -raw work_uri
terraform output -raw work_bucket_name
terraform output -raw nextflow_policy_arn
```

Set `workDir` to the returned `work_uri` and configure `process.executor` as `awsbatch` with `compute_queue_name` for compute jobs. Use `head_queue_name` for head jobs when your Nextflow configuration separates them. The external service that starts the workflow must assume or use the IAM role with `nextflow_policy_arn` attached. That policy grants the required S3 work-directory access and AWS Batch submit/describe permissions.

## Files

- `versions.tf`: Terraform and AWS provider version constraints
- `providers.tf`: AWS provider configuration
- `main.tf`: shared tags and module invocation
- `variables.tf`: deployment inputs
- `outputs.tf`: useful module outputs
- `terraform.tfvars.example`: safe configuration template
- `../modules/nf-aws-batch`: reusable S3 and IAM module

## Secrets for use with nfcc instance

```
cd /home/q/nf-azure/azure

terraform output -json |
jq '{
  azure_tenant_id: .entra_tenant_id.value,
  azure_service_principal_id: .entra_client_id.value,
  azure_service_principal_secret: .entra_client_secret.value,
  azure_batch_account_name: .batch_account_name.value,
  azure_batch_endpoint: ("https://" + .batch_account_endpoint.value),
  azure_location: "eastus",
  azure_storage_account_name: .storage_account_name.value,
  azure_storage_container: .storage_container_name.value,
  azure_allow_pool_creation: true,
  azure_auto_pool_mode: true,
  azure_delete_pools_on_completion: true,
  azure_machine_type: "Standard_D2s_v3",
  driver_registry: {
    registry_url: "nfcr.azurecr.io"
  },
  drive_image: "nfcr.azurecr.io/nextflow/nextflow-azure:26.04.6"
}'
```