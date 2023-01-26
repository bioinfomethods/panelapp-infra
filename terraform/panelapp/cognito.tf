data "aws_ssm_parameter" "google_oauth_client_id" {
  count = "${var.use_cognito ? 1 : 0}"
  name  = "/${var.stack}/${var.env_name}/cognito/google/oauth_client_id"
}

data "aws_ssm_parameter" "google_oauth_client_secret" {
  count = "${var.use_cognito ? 1 : 0}"
  name  = "/${var.stack}/${var.env_name}/cognito/google/oauth_client_secret"
}

resource "aws_cognito_user_pool" "pool" {
  count                    = "${var.use_cognito ? 1 : 0}"
  name                     = "${var.stack}-${var.env_name}"
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  schema {
    name                = "email"
    required            = true
    mutable             = true
    attribute_data_type = "String"

    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  schema {
    name                = "family_name"
    required            = true
    mutable             = true
    attribute_data_type = "String"

    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  schema {
    name                = "given_name"
    required            = true
    mutable             = true
    attribute_data_type = "String"

    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  admin_create_user_config {
    allow_admin_create_user_only = "${var.cognito_allow_admin_create_user_only}"
    # unused_account_validity_days = 7
  }

  password_policy {
    minimum_length    = "${var.cognito_password_length}"
    require_lowercase = true
    require_numbers   = true
    require_symbols   = "${var.cognito_password_symbols_required}"
    require_uppercase = true
    temporary_password_validity_days = 7
  }

  tags = "${merge(var.default_tags, map("Name", "${var.stack}-${var.env_name}"))}"
}

resource "aws_cognito_identity_provider" "google" {
  count         = "${var.use_cognito ? 1 : 0}"
  user_pool_id  = "${aws_cognito_user_pool.pool.id}"
  provider_name = "Google"
  provider_type = "Google"

  provider_details   = {
    client_id        = "${data.aws_ssm_parameter.google_oauth_client_id.value}"
    client_secret    = "${data.aws_ssm_parameter.google_oauth_client_secret.value}"
    authorize_scopes = "openid profile email"
  }

  attribute_mapping = {
    email           = "email"
    username        = "sub"
    given_name      = "given_name"
    family_name     = "family_name"
    email_verified  = "email_verified"
  }
}

resource "aws_cognito_user_pool_client" "client" {
  count                  = "${var.use_cognito ? 1 : 0}"
  name                   = "${var.stack}-${var.env_name}"
  user_pool_id           = "${aws_cognito_user_pool.pool.id}"

  generate_secret        = true
  refresh_token_validity = 30

  // App client settings
  //FIXME supported_identity_providers = ["COGNITO", "${aws_cognito_identity_provider.google.provider_name}"]
  supported_identity_providers = ["${aws_cognito_identity_provider.google.provider_name}"]

  callback_urls = [
    "https://${var.cdn_alis}/oauth2/idpresponse",
  ]

  logout_urls = [
    "https://${var.cdn_alis}/accounts/logout/"
  ]

  default_redirect_uri                 = "https://${var.cdn_alis}/oauth2/idpresponse"
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid", "profile", "email"]
  allowed_oauth_flows_user_pool_client = true
}

resource "aws_cognito_user_pool_domain" "domain" {
  count        = "${var.use_cognito ? 1 : 0}"
  domain       = "${var.stack}-${var.env_name}"
  user_pool_id = "${aws_cognito_user_pool.pool.id}"
}

resource "aws_lb_listener_rule" "accounts" {
  count        = "${var.use_cognito ? 1 : 0}"
  priority     = 100
  listener_arn = "${aws_lb_listener.panelapp_app_web.arn}"

  action {
    type = "authenticate-cognito"

    authenticate_cognito {
      scope                      = "openid profile email"
      user_pool_arn              = "${aws_cognito_user_pool.pool.arn}"
      user_pool_domain           = "${aws_cognito_user_pool_domain.domain.domain}"
      user_pool_client_id        = "${aws_cognito_user_pool_client.client.id}"
      on_unauthenticated_request = "authenticate"
    }
  }

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.panelapp_app_web.arn}"
  }

  condition {
    path_pattern {
      values = ["${var.cognito_alb_app_login_path}"]
    }
  }
}

resource "aws_security_group_rule" "egress_cognito" {
  count     = "${var.use_cognito ? 1 : 0}"
  type      = "egress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  cidr_blocks       = ["0.0.0.0/0"]
  description       = "egress for panelapp cognito"
  security_group_id = "${aws_security_group.panelapp_elb.id}"
}
