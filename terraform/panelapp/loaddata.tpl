[
  {
    "name": "panelapp-loaddata",
    "image" : "784145085393.dkr.ecr.eu-west-2.amazonaws.com/panelapp-web:latest",
    "entryPoint": ["sh","-c"],
    "command": ["python -c \"import boto3,botocore;boto3.resource('s3').Bucket('panelapp-media').download_file('genes.json.gz', '/var/tmp/genes.json.gz')\" ; python manage.py loaddata --verbosity 3 /var/tmp/genes.json"],
    "cpu": 512,
    "memory": 1024,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "panelapp",
        "awslogs-stream-prefix": "panelapp",
        "awslogs-region": "eu-west-2"
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
    { "name" : "AWS_S3_STATICFILES_BUCKET_NAME", "value" : "panelapp-statics" },
    { "name" : "AWS_S3_MEDIAFILES_BUCKET_NAME", "value" : "panelapp-media" },
    { "name" : "AWS_S3_STATICFILES_CUSTOM_DOMAIN", "value" : "${cdn_domain_name}" },
    { "name" : "ALLOWED_HOSTS", "value" : "*" },
    { "name" : "DEFAULT_FROM_EMAIL", "value" : "panelapp@local.com" },
    { "name" : "PANEL_APP_EMAIL", "value" : "panelapp@local.com" },
    { "name" : "EMAIL_HOST", "value" : "local.com" },
    { "name" : "EMAIL_PORT", "value" : "25" }

]
}
]
