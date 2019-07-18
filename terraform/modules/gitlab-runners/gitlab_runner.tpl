[
  {
    "cpu": ${app_cpu},
    "image": "${app_image}",
    "memory": ${app_memory},
    "name": "terraform",
    "networkMode": "awsvpc",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "gitlab-runners",
        "awslogs-stream-prefix": "terraform",
        "awslogs-region": "${app_region}"
      }
    },
    "environment": [
      {
        "name": "RUNNER_NAME",
        "value": "terraform"
      },
      {
        "name": "RUNNER_TAG_LIST",
        "value": "terraform,${additional_runner_tag}"
      },
      {
        "name": "RUNNER_EXECUTOR",
        "value": "shell"
      },
      {
        "name": "RUNNER_REQUEST_CONCURRENCY",
        "value": "2"
      },
      {
        "name": "CI_SERVER_URL",
        "value": "https://gitlab.com"
      }
    ],
    "secrets": [
        {
              "name": "REGISTRATION_TOKEN",
              "valueFrom": "${gitlab_runner_token}"
        },
        {
              "name": "CLOUDFLARE_EMAIL",
              "valueFrom": "${cloudflare_email}"
        },
        {
              "name": "CLOUDFLARE_TOKEN",
              "valueFrom": "${cloudflare_token}"
        }
    ],
    "portMappings": []
  }
]
