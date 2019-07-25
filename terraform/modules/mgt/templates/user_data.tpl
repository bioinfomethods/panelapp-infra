#cloud-config
runcmd:
- [ amazon-linux-extras, install, postgresql9.6, -y ]
- [ amazon-linux-extras, install, docker, -y ]
- [ systemctl, enable, --now, docker ]
- [ usermod, -a, -G, docker, ec2-user ]
- [ usermod, -a, -G, docker, ssm-user ]
- [ yum, install, jq python2-pip, -y ]
- [ pip, install, docker-compose ]
- [ echo "PGPASSWORD=$(aws --region eu-west-2 ssm get-parameters --name /panelapp/test/database/master_password --with-decryption | jq -r .Parameters[].Value) >> /home/ssm-user/ ]

write_files:
- path: /etc/profile.d/ssm_vars.sh
  content |
    PGPASSWORD=$(aws --region eu-west-2 ssm get-parameters --name /panelapp/test/database/master_password --with-decryption | jq -r '.Parameters[].Value')
- path: /home/ssm-user/docker-compose.yml   
  content: |
    version: '3'
    services:
      web:
        image: ${image_name}:${image_tag}
        restart: "no"
        environment:
          - DATABASE_HOST=${database_host}
          - DATABASE_PORT=${database_port}
          - DATABASE_NAME=${database_name}
          - DATABASE_USER=${database_user}
          - DATABASE_PASSWORD=${db_password}
          - AWS_REGION=${aws_region}
          - AWS_S3_STATICFILES_BUCKET_NAME=${panelapp_statics}
          - AWS_S3_MEDIAFILES_BUCKET_NAME=${panelapp_media}
          - AWS_S3_STATICFILES_CUSTOM_DOMAIN=${cdn_domain_name}
          - AWS_S3_MEDIAFILES_CUSTOM_DOMAIN=${cdn_domain_name}
          - DJANGO_LOG_LEVEL=INFO
          # Not used by the management box
          - DEFAULT_FROM_EMAIL=dummy@dummy.com
          - PANEL_APP_EMAIL=dummy@dummy.com
          - EMAIL_HOST=localhost
          - EMAIL_PORT=25
          - PANEL_APP_BASE_URL=http://localhost
        entrypoint:
          - python
          - manage.py
          - shell
