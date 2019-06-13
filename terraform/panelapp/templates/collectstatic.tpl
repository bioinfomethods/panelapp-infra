[
  {
    "name": "panelapp-collectstatic",
    "image" : "784145085393.dkr.ecr.eu-west-2.amazonaws.com/panelapp-web:latest",
    "entryPoint": ["sh","-c"],
    "command": ["python manage.py collectstatic --noinput"],
    "cpu": 512,
    "memory": 1024,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "panelapp-collectstatic",
        "awslogs-stream-prefix": "panelapp-collectstatic",
        "awslogs-region": "${aws_region}"
      }
    },
    "portMappings": [
        {
          "containerPort": 8080
        }
    ],
    "environment" : [
      { "name" : "DATABASE_HOST", "value" : "${database_host}" },
      { "name" : "DATABASE_PORT", "value" : "${database_port}" },
      { "name" : "DATABASE_NAME", "value" : "${database_name}" },
      { "name" : "DATABASE_USER", "value" : "${database_user}" },
      { "name" : "DJANGO_LOG_LEVEL", "value" : "DEBUG" },
      { "name" : "AWS_REGION", "value" : "${aws_region}" },
      { "name" : "AWS_S3_STATICFILES_BUCKET_NAME", "value" : "${panelapp_statics}" },
      { "name" : "AWS_S3_MEDIAFILES_BUCKET_NAME", "value" : "${panelapp_media}" },
      { "name" : "AWS_S3_STATICFILES_CUSTOM_DOMAIN", "value" : "${cdn_domain_name}" }
    ],
    "secrets": [
      { "name": "DATABASE_PASSWORD", "valueFrom": "${db_password_secret_arn}" }
    ]
  }
]
