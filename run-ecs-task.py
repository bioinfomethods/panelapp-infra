#!/usr/local/bin/python3

# This is just an example to start one off task, has to be improved

import boto3
from botocore.exceptions import ClientError


security_group_ids = []
ec2 = boto3.client('ec2')
security_groups = ['panelapp-fargate-panelapp-dev','aurora-dev']

for security_group in security_groups:
	response = ec2.describe_security_groups(
    Filters=[
        dict(Name='group-name', Values=[security_group])
    ]
)
	security_group_ids.append(response['SecurityGroups'][0]['GroupId'])


tasks=['panelapp-migrate-panelapp-dev','panelapp-collectstatic-panelapp-dev','panelapp-loaddata-panelapp-dev','panelapp-createsuperuser-panelapp-dev']
ecs = boto3.client('ecs')

for task in tasks:
  try:
    run_task = ecs.run_task(
  		cluster='panelapp-cluster-dev',
  		launchType = 'FARGATE',
  		taskDefinition=task,
  		count = 1,
  		platformVersion='LATEST',
  		networkConfiguration={
        'awsvpcConfiguration': {
            'subnets': [
                'subnet-05d4f3d7e97901d41',
                'subnet-0c4fe09b0863c883e'
            ],
            'securityGroups': security_group_ids,
            'assignPublicIp': 'ENABLED'
        	}
    	})
  except ClientError as e:
  	print (e)
