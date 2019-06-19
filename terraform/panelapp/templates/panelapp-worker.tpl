[
  {
    "name": "panelapp-worker",
    "image" : "${image_name}:${image_tag}",
    "cpu": ${cpu},
    "memory": ${memory},
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "panelapp-worker",
        "awslogs-stream-prefix": "panelapp-worker",
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
      { "name" : "AWS_S3_MEDIAFILES_BUCKET_NAME", "value" : "${panelapp_media}" },
      { "name" : "DEFAULT_FROM_EMAIL", "value" : "${default_email}" },
      { "name" : "PANEL_APP_EMAIL", "value" : "${panelapp_email}" },
      { "name" : "EMAIL_HOST", "value" : "${email_host}" },
      { "name" : "EMAIL_PORT", "value" : "587" },
      { "name" : "EMAIL_HOST_USER", "value" : "${email_user}" },
      { "name" : "EMAIL_HOST_PASSWORD", "value" : "${email_password}" }
    ],
    "secrets": [
      { "name": "DATABASE_PASSWORD", "valueFrom": "${db_password_secret_arn}" }
    ]
  }
]