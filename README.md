# Notes about cloud-native PanelApp porting

> This repo has a submodule, containing the PanelApp application hosted on GitHub.
> Clone it with `--recurse-submodules` (`git clone --recurse-submodules ...`)

## Terraform state

Terraform state S3 bucket and lock DynamoDB table must be created "by hand" before running the code

## Installation-specific configuration


Backend must be configured through a file like this:

```
region = "eu-west-2"
bucket = "panelapp-dev-<ACCOUNT-ID>-eu-west-2-terraform-state"
key = "<COMPONENT>/terraform.tfstate"
encrypt = true
dynamodb_table = "terraform-lock"
```

Where:

* `<COMPONENT>` is either `site` or `panelapp`
* `<ACCOUNT-ID>` is the AWS account ID


Init terraform with `-backend-config=<FILE>`. 

Where `<FILE>` is the path to the file containing the backend configuration above


Installations-specific parameters to be provided:

* `env_name`
* `account_id`
* `region`
* `public_dns_zone_name`

The easiest way is creating a `terraform.tfvars` with them and put it in both `./site` and `./panelapp` subdirectories.
