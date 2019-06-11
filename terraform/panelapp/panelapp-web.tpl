[
  {
    "name": "panelapp-web",
    "image" : "784145085393.dkr.ecr.eu-west-2.amazonaws.com/panelapp-web:latest",
    "cpu": 512,
    "memory": 1024,
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
    { "name" : "DATABASE_URL", "value" : "${database_url}" },
    { "name" : "DJANGO_LOG_LEVEL", "value" : "DEBUG" },
    { "name" : "AWS_REGION", "value" : "${aws_region}" },
    { "name" : "AWS_S3_STATICFILES_BUCKET_NAME", "value" : "${panelapp_statics}" },
    { "name" : "AWS_S3_MEDIAFILES_BUCKET_NAME", "value" : "${panelapp_media}" },
    { "name" : "AWS_S3_STATICFILES_CUSTOM_DOMAIN", "value" : "${cdn_domain_name}" },
    { "name" : "ALLOWED_HOSTS", "value" : "*" },
    { "name" : "DEFAULT_FROM_EMAIL", "value" : "${default_email}" },
    { "name" : "PANEL_APP_EMAIL", "value" : "${panelapp_email}" },
    { "name" : "EMAIL_HOST", "value" : "${email_host}" },
    { "name" : "EMAIL_PORT", "value" : "587" },
    { "name" : "EMAIL_HOST_USER", "value" : "${email_user}" },
    { "name" : "EMAIL_HOST_PASSWORD", "value" : "${email_password}" }

]
}
]
