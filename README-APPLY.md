# Create nextflow environment

```sh

terraform init

terraform plan \
   -var resource_group_name=nf-azure \
   -var location=centralus


```

```sh
terraform apply \
   -var=resource_group_name=nf-azure \
   -var=location=centralus
```

The deployment creates the Batch account, Storage account, private `work` container, and Entra service principal. The service principal secret is stored in Terraform state and is marked sensitive.

Retrieve the non-secret Nextflow settings:

```sh
terraform output -raw entra_tenant_id
terraform output -raw entra_client_id
terraform output -raw batch_account_name
terraform output -raw batch_account_endpoint
terraform output -raw storage_account_name
```

Set the one secret as an environment variable without writing it into the Nextflow config:

```sh
export AZURE_CLIENT_SECRET="$(terraform output -raw entra_client_secret)"
cp nextflow.azure.config.example nextflow.azure.config
nextflow run <pipeline> -c nextflow.azure.config
```