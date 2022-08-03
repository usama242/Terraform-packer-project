# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Env variables for Packer
Add the following environment variables

AZ_SUSCRIPTION_ID
AZ_CLIENT_ID
AZ_CLIENT_SECRET
AZ_TENANT_ID
RESOURCE_GROUP_NAME
### Instructions
1. Deploy the policy
```
    cd policy
    create_policy.sh
```

2. Create a custom image using Packer
```
    $ cd packer
    $ packer build packer/server.json
```

3. Provision infrastructure usint Terraform
```
    $ cd terraform
    $ terraform init
    $ terraform plan -out -solution.plan
    $ terraform apply --auto-approve
```

4. If you want to destroy the resouces
```
    $ terraform destroy
```

### Modify
If you want to use your own variable instead of default, user terraform.tfvars file
