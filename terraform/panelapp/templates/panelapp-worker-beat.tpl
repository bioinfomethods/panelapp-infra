[
  {
    "name": "panelapp-worker-beat",
    "image" : "${image_name}:${image_tag}",
    "entryPoint": ["celery", "beat"],
    "command": ["--pidfile=","-s","/tmp/celerybeat-schedule","-A","panelapp"],
    "cpu": ${cpu},
    "memory": ${memory},
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "panelapp-worker-beat",
        "awslogs-stream-prefix": "panelapp-worker-beat",
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
      { "name" : "PANEL_APP_BASE_URL", "value" : "https://${panel_app_base_host}" },
      { "name" : "DJANGO_ADMIN_URL", "value" : "${admin_url}" },
      { "name" : "GUNICORN_WORKERS", "value" : "${gunicorn_workers}" },
      { "name" : "GUNICORN_TIMEOUT", "value" : "${gunicorn_timeout}" },
      { "name" : "EMAIL_HOST_USER", "value" : "${email_user}" },
      { "name" : "EMAIL_HOST_PASSWORD", "value" : "${email_password}" },
      { "name" : "ACTIVE_SCHEDULED_TASKS", "value": "${active_scheduled_tasks}" },
      { "name" : "MOI_CHECK_DAY_OF_WEEK", "value": "${moi_check_day_of_week}" }
    ],
    "secrets": [
      { "name": "DATABASE_PASSWORD", "valueFrom": "${db_password_secret_arn}" },
      { "name": "OMIM_API_KEY", "valueFrom": "${omim_api_secret_arn}" }
    ]
  }
]