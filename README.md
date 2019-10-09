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

## Cognito

Using AWS Cognito for user and authentication purpose is totally **optional**. This is set by `use_cognito` variable. The following variables are introduced and configurable.

* `use_cognito` - Boolean variable whether to use Cognito. Default to `false`.
* `cognito_alb_app_login_path` - PanelApp login path to be intercepted by ALB Cognito authenticate action. Default to `/accounts/login/*`.
* `cognito_allow_admin_create_user_only` - Only allow administrators to create users in Cognito User Pool. Default to `true`.
* `cognito_password_length` - Cognito User Pool user password length. Default to `10`.
* `cognito_password_symbols_required` - Cognito password special character required. Default to `false`.

The Cognito implementation is based on the following articles.

* https://aws.amazon.com/blogs/aws/built-in-authentication-in-alb/
* https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-identity-pools.html
* https://docs.aws.amazon.com/elasticloadbalancing/latest/application/listener-authenticate-users.html

### Third Party IdP Support

Cognito User Pool support [third party IdP and user federation for Single Sign-On](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pools-identity-federation.html) (SSO) purpose. Current deployment implementation support this SSO feature by using **Google** as the third party IdP and this is enabled by default. Therefore, if you intend to use Cognito in your deployment, it is required to setup Google API credentials for [OAuth 2.0 client](https://support.google.com/googleapi/answer/6158849) purpose as follows.

1. Go to [Google API console](https://console.developers.google.com/).
2. Create a new API project.
3. On the left, click **Credentials**.
    1. Click **New Credentials**, then select **OAuth client ID**
    2. Select **Web application** as application type
    3. Give name e.g. `PanelApp`
    4. At **Authorized JavaScript origins**, add `https://panelapp-prod.auth.ap-southeast-2.amazoncognito.com`.
    5. At **Authorized redirect URIs**, add `https://panelapp-prod.auth.ap-southeast-2.amazoncognito.com/oauth2/idpresponse`.
4. On the left, click **OAuth consent screen**.
    1. At **Scopes for Google APIs**, add scope for `email`, `profile`, `openid`. Note, one at a time.
    2. At **Authorized domains**, add `amazoncognito.com`

After Google OAuth 2.0 client is created, its credential must be stored in AWS SSM Parameter Store (just like database master password) as follows. Replace `<Client ID>` and `<Client secret>` with values generated from Step 3.

```
aws ssm put-parameter --name '/panelapp/prod/cognito/google/oauth_client_id' --type "SecureString" --value '<Client ID>'
aws ssm put-parameter --name '/panelapp/prod/cognito/google/oauth_client_secret' --type "SecureString" --value '<Client secret>'
```

Note that the domain `panelapp-prod` and `/panelapp/prod/...` is derived from terraform variables `${var.stack}` and `${var.env_name}`. Currently only Hosted UI mode is tested and supported.
