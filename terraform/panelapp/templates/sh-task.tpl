[
  {
    "name": "${container_name}",
    "image" : "${image_name}:${image_tag}",
    "entryPoint": ["sh","-c"],
    "command": ["${command}"],
    "cpu": ${cpu},
    "memory": ${memory},
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group}",
        "awslogs-stream-prefix": "${log_stream_prefix}",
        "awslogs-region": "${aws_region}"
      }
    },
    "environment" : [
      { "name" : "DATABASE_HOST", "value" : "${database_host}" },
      { "name" : "DATABASE_PORT", "value" : "${database_port}" },
      { "name" : "DATABASE_NAME", "value" : "${database_name}" },
      { "name" : "DATABASE_USER", "value" : "${database_user}" },
      { "name" : "DJANGO_LOG_LEVEL", "value" : "${log_level}" },
      { "name" : "AWS_REGION", "value" : "${aws_region}" },
      { "name" : "AWS_S3_STATICFILES_BUCKET_NAME", "value" : "${panelapp_statics}" },
      { "name" : "AWS_S3_MEDIAFILES_BUCKET_NAME", "value" : "${panelapp_media}" },
      { "name" : "AWS_S3_STATICFILES_CUSTOM_DOMAIN", "value" : "${cdn_domain_name}" },
      { "name" : "ALLOWED_HOSTS", "value" : "*" },
      { "name" : "DEFAULT_FROM_EMAIL", "value" : "${default_email}" },
      { "name" : "PANEL_APP_EMAIL", "value" : "${panelapp_email}" },
      { "name" : "EMAIL_HOST", "value" : "${email_host}" },
      { "name" : "EMAIL_PORT", "value" : "587" },
      { "name" : "PANEL_APP_BASE_URL", "value" : "https://${panel_app_base_host}" },
      { "name" : "DJANGO_ADMIN_URL", "value" : "${admin_url}" },
      { "name" : "GUNICORN_WORKERS", "value" : "${gunicorn_workers}" },
      { "name" : "GUNICORN_TIMEOUT", "value" : "${gunicorn_timeout}" },
      { "name" : "EMAIL_HOST_USER", "value" : "${email_user}" },
      { "name" : "EMAIL_HOST_PASSWORD", "value" : "${email_password}" }
    ],
    "secrets": [
      { "name": "DATABASE_PASSWORD", "valueFrom": "${db_password_secret_arn}" }
    ]
  }
]
