[
  {
    "name": "panelapp-web",
    "image" : "${image_name}:${image_tag}",
    "cpu": ${cpu},
    "command": [
      "ddtrace-run", "gunicorn", "--worker-tmp-dir=/dev/shm", "--config=file:/app/gunicorn_config.py", "panelapp.wsgi:application"
    ],
    "memory": ${memory},
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "panelapp-web",
        "awslogs-stream-prefix": "panelapp-web",
        "awslogs-region": "${aws_region}"
      }
    },
    "portMappings": [
        {
          "containerPort": 8080
        }
    ],
    "environment" : [
      { "name" : "ENV_NAME", "value" : "${env_name}" },
      { "name" : "DATABASE_HOST", "value" : "${database_host}" },
      { "name" : "DATABASE_PORT", "value" : "${database_port}" },
      { "name" : "DATABASE_NAME", "value" : "${database_name}" },
      { "name" : "DATABASE_USER", "value" : "${database_user}" },
      { "name" : "DJANGO_LOG_LEVEL", "value" : "${log_level}" },
      { "name" : "AWS_REGION", "value" : "${aws_region}" },
      { "name" : "AWS_S3_STATICFILES_BUCKET_NAME", "value" : "${panelapp_statics}" },
      { "name" : "AWS_S3_MEDIAFILES_BUCKET_NAME", "value" : "${panelapp_media}" },
      { "name" : "AWS_S3_STATICFILES_CUSTOM_DOMAIN", "value" : "${cdn_domain_name}" },
      { "name" : "AWS_S3_MEDIAFILES_CUSTOM_DOMAIN", "value" : "${cdn_domain_name}" },
      { "name" : "ALLOWED_HOSTS", "value" : "*" },
      { "name" : "DEFAULT_FROM_EMAIL", "value" : "${default_email}" },
      { "name" : "PANEL_APP_EMAIL", "value" : "${panelapp_email}" },
      { "name" : "EMAIL_HOST", "value" : "${email_host}" },
      { "name" : "EMAIL_PORT", "value" : "587" },
      { "name" : "PANEL_APP_BASE_URL", "value" : "https://${panel_app_base_host}" },
      { "name" : "DJANGO_ADMIN_URL", "value" : "${admin_url}" },
      { "name" : "GUNICORN_WORKERS", "value" : "${gunicorn_workers}" },
      { "name" : "GUNICORN_TIMEOUT", "value" : "${gunicorn_timeout}" },
      { "name" : "GUNICORN_ACCESSLOG", "value" : "${gunicorn_accesslog}" },
      { "name" : "GUNICORN_ACCESS_LOG_FORMAT", "value" : "%({cf-connecting-ip}i)s %(l)s %(u)s %(t)s \"%(r)s\" %(s)s %(b)s \"%(f)s\" \"%(a)s\"" },
      { "name" : "EMAIL_HOST_USER", "value" : "${email_user}" },
      { "name" : "EMAIL_HOST_PASSWORD", "value" : "${email_password}" },
      { "name" : "AWS_USE_COGNITO", "value" : "${aws_use_cognito}" },
      { "name" : "AWS_COGNITO_DOMAIN_PREFIX", "value" : "${aws_cognito_domain_prefix}" },
      { "name" : "AWS_COGNITO_USER_POOL_CLIENT_ID", "value" : "${aws_cognito_user_pool_client_id}" },
      { "name" : "DJANGO_SETTINGS_MODULE", "value" : "panelapp.settings.docker-aws" }
    ],
    "secrets": [
      { "name": "DATABASE_PASSWORD", "valueFrom": "${db_password_secret_arn}" }
    ]
  }
]
