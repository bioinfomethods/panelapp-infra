# Cloud-PanelApp AWS infra-as-code

## Project structure and multi-environment support

This code has been designed to be multi-environment (e.g. "test", "stage", "prod").

Each environment is supposed to be installed in a **separate AWS account**, plus a *shared* account with some 
cross-environment resources, like to top level DNS Zone.

The Terraform code for the environments is split into two separate Terraform projects (components):

1. [infra](terraform/infra): Resources build when the new environment is created and probably never changed (e.g. VPC, DNS, KMS...)
2. [panelapp](terraform/panelapp): Resource specific to the PanelApp application (e.g. Fargate, Aurora, SQS...).
    This Terraform code is also supposed to be used for deploying a new version of the application (a new docker image tag)
    or any configuration change.
    
The Terraform code for the *shared* account sits in a third, [separate component](terraform/shared).

### Configuration

Each AWS account (one per environment, plus *shared*) needs a separate configuration.

The configuration of each Terraform component has two parts:

1. A `.tfvars` file, containing all parameters specific to the account/environment.
    *infra* and *panelapp* components use the same `.tfvars` file.
    Examples:
    [*infra* and *panelapp* configuration](terraform/terraform-example.tfvars), 
    [*shared* configuration](terraform/shared/terraform-shared-example.tfvars)
2. A backend configuration file, to configure Terraform state backend (S3 and DynamoDB). Beware the backend of *infra* 
    and *panelapp* are NOT identical.
    Examples:
    [*infra* backend configuration](terraform/infra/backend-infra-example.conf),
    [*panelapp* backend configuration](terraform/panelapp/backend-panelapp-example.conf),
    [*shared* backend configuration](terraform/shared/backend-shared-example.conf)

## Terraform state backend initialisation

Terraform state and lock are in a S3 bucket and DynamoDB table, respectively.

> Terraform has an egg-and-chicken problem: we must create the S3 bucket and DynamoDB table at the first run,
> without specifying any backend, than we re-init Terraform explicitly specifying the backend.

After completing the configuration files, you need to follow the following process to initialise the Terraform backend
**for each component** (infra, panelapp, shared) and **for each AWS account** (e.g. *test*, *stage*, *prod*)


**This is required only the first time someone run a component on an account, to create the S3 bucket and DynamoDB table.**

1. Comment out  `backend "s3" {}` in `main.tf` 
2. Run `terraform init` without any parameter
3. Run `terraform apply`. This will also create the state bucket and lock table.
4. Remove the comment in `main.tf`
5. Initialise Terraform again, specifying the backend configuration:
    `terraform init -backend-config=<backand-config-file>` 
6. Run `terraform plan`. This will push the state to S3

Once the state bucket and table have been created, any following use of terraform only requires initialising the backend
normally, with  `terraform init -backend-config=<backand-config-file>` 

Bucket and table follow this naming convention (this may be changed in the configuration, but be sure to do it consistently 
across all components and environments).

* S3 bucket: `<STACK>-<ENV>-<ACCOUNT-ID>-<REGION>-terraform-state` (e.g. `panelapp-dev-123456789012-eu-west-2-terraform-state`)
* DynamoDB table: `<STACK>-<ENV>-terraform-lock` (e.g. `panelapp-dev-terraform-lock`)
