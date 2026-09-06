# nf-azure

Terraform baseline for deploying a low-cost Nextflow execution environment on Microsoft Azure Batch. It creates a resource group, Batch account, Standard/LRS StorageV2 account, and private Blob container without a VNet.

The Batch, Storage, and Microsoft Entra resources are exposed through the reusable `modules/nextflow-azure-batch` module.

## Cost mode

Azure Batch does not have a separate free tier. This configuration creates the Batch control plane but no compute nodes or Batch pool. With Nextflow `autoPoolMode = true` and `allowPoolCreation = true`, Nextflow can create and remove pools for workflow runs. VM compute charges apply while those pools have nodes.

The module creates the shared Blob container required by Nextflow and an Entra service principal with `Azure Batch Data Contributor` on the Batch account and `Storage Blob Data Contributor` on the Storage account. Storage shared-key support remains enabled because the AzureRM provider requires it to manage some account properties, but keys are not exposed as Terraform outputs or used by Nextflow. Configure `workDir` as `az://work` and use the Terraform outputs for the account names, endpoint, tenant ID, client ID, and client secret. The client secret is the only credential value you need to supply to Nextflow; protect the Terraform state because it contains that secret.

Example Nextflow authentication configuration:

```groovy
azure {
	activeDirectory {
		tenantId = '<terraform output entra_tenant_id>'
		servicePrincipalId = '<terraform output entra_client_id>'
		servicePrincipalSecret = '<terraform output entra_client_secret>'
	}
	batch {
		accountName = '<terraform output batch_account_name>'
		endpoint = '<terraform output batch_account_endpoint>'
		autoPoolMode = true
		allowPoolCreation = true
	}
	storage {
		accountName = '<terraform output storage_account_name>'
	}
}
```

The complete copyable template is `nextflow.azure.config.example`. After applying Terraform, set the one secret in the environment and replace the identifier placeholders in that template:

```bash
export AZURE_CLIENT_SECRET="$(terraform output -raw entra_client_secret)"
cp nextflow.azure.config.example nextflow.azure.config
nextflow run <pipeline> -c nextflow.azure.config
```

The service principal must be allowed to create role assignments only during Terraform deployment; the generated principal itself receives access only to the Batch and Storage resources. The identity running Terraform needs permission to create Entra applications/service principals and assign Azure RBAC roles.

This project does not create a VNet because Azure Batch can be configured without one; add network integration later if private data access or network isolation requires it.

## Prerequisites

- Terraform 1.7 or newer
- Azure CLI
- An Azure subscription in which you can create resource groups

## Authenticate

```bash
az login
az account set --subscription "<subscription-id>"
```

The AzureRM provider uses the active Azure CLI session by default. For automation, use workload identity federation or a service principal supplied through standard `ARM_*` environment variables. Do not store credentials in Terraform files.

## Configure

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` for the target environment. It is ignored by Git because variable files may contain sensitive values.

## Deploy

```bash
terraform init
terraform fmt -check
terraform validate
terraform plan -out=nf-azure.tfplan
terraform apply nf-azure.tfplan
```

Review every plan before applying it. To remove the resources later, run `terraform destroy` after reviewing the destroy plan.

## Files

- `versions.tf`: Terraform and provider version constraints
- `providers.tf`: AzureRM provider configuration
- `main.tf`: Azure resources and shared tags
- `variables.tf`: configurable project inputs
- `outputs.tf`: resource identifiers emitted after deployment
- `modules/nextflow-azure-batch`: reusable Batch, Storage, Entra service principal, and private container module
- `nextflow.azure.config.example`: Nextflow Entra authentication and auto-pool configuration template
- `terraform.tfvars.example`: safe configuration template