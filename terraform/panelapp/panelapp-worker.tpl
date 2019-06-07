[
{

    "name": "panelapp-worker",
    "image" : "784145085393.dkr.ecr.eu-west-2.amazonaws.com/panelapp-worker:latest",
    "cpu": 512,
    "memory": 1024,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "panelapp-worker",
        "awslogs-stream-prefix": "panelapp-worker",
        "awslogs-region": "eu-west-2"
      }

  },
  "environment" : [
    { "name" : "DATABASE_URL", "value" : "${database_url}" },
    { "name" : "DJANGO_LOG_LEVEL", "value" : "DEBUG" },
    { "name" : "AWS_REGION", "value" : "${aws_region}" },
    { "name" : "AWS_S3_MEDIAFILES_BUCKET_NAME", "value" : "panelapp-media" },
    { "name" : "DEFAULT_FROM_EMAIL", "value" : "panelapp@local.com" },
    { "name" : "PANEL_APP_EMAIL", "value" : "panelapp@local.com" },
    { "name" : "EMAIL_HOST", "value" : "local.com" },
    { "name" : "EMAIL_PORT", "value" : "25" }

]
}
]