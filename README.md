# Notes about cloud-native PanelApp porting

> This repo has a submodule, containing the PanelApp application hosted on GitHub.
> Clone it with `--recurse-submodules` (`git clone --recurse-submodules ...`)

## Terraform state backend

Terraform state and lock are in a S3 bucket and DynamoDB table, respectively.

> Terraform has an egg-and-chicken problem: we must create the S3 bucket and DynamoDB table at the first run,
> without specifying any backend, than we re-init Terraform explicitly specifying the backend.

1. `init` Terraform without any backend configuration and `apply`: this will also create the state bucket and lock table
2. `init` Terraform with a backend configuration (see below): 

Bucket and table are automatically created at the first run, with the following naming:

* S3 bucket: `<STACK>-<ENV>-<ACCOUNT-ID>-<REGION>-terraform-state` (e.g. `panelapp-dev-123456789012-eu-west-2-terraform-state`)
* DynamoDB table: `<STACK>-<ENV>-terraform-lock` (e.g. `panelapp-dev-terraform-lock`)

### Backend explicit configuration

After the first run, Terraform must be explicitly `init` to use the backend.
Unfortunately, it cannot infer bucket and table names, event though it created them.

1. In both `./infra` and `./panelapp` directories, create a file with the following content:
    ```
    region = "<REGION>"
    bucket = "panelapp-dev-<ACCOUNT-ID>-eu-west-2-terraform-state"
    key = "<COMPONENT>/terraform.tfstate"
    encrypt = true
    dynamodb_table = "panelapp-dev-terraform-lock"
    ```
    * `<REGION>`: AWS Region
    * `<ACCOUNT-ID>`: AWS account ID
    * `<COMPONENT>`: either `infra` or `panelapp`. **Note that the files in `./infra` and `./panelapp` are different**
2. Initialize Terraform configuring the backend
    ```
    $ terraform init -backend-config=<FILEPATH>
    ```
    * `<FILEPATH>` backend config file


## Installation-specific configuration

The following installation-specific variables must be provided:

* `env_name`
* `account_id`
* `region`
* `public_dns_zone_name`

The easiest way is creating a `terraform.tfvars` with them and put it in both `./infra` and `./panelapp` subdirs.

## DNS Zone delegation and SSL Certs

The Terraform `infra` module is also generating SSL Certificates for CloudFront CDN by default.

The certificate validation requires the DNS Zone to be fully visible from the Internet. 
This may require and additional step, for delegating the DNS Zone to the `NS` Route53 is using for the Zone.

1. Generate `infra` without generating SSL Certificates: `terraform apply -var="generate_ssl_certs=false"`
    Zone NS are part of the output (`public_dns_zone_ns`)
2. Do any external operation to delegate the DNS Zone to these NS
3. Re-`apply` `infra` to also generate SSL Certificates (i.e. without overriding `generate_ssl_certs=false`)
