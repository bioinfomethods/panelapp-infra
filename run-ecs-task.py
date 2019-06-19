#!/usr/local/bin/python3

# This is just an example to start one off task, has to be improved

import boto3
from botocore.exceptions import ClientError

def get_security_id(sec_group_names):

  """
  This returns the security group ids by providing the group names
  """
  ec2 = boto3.client('ec2')
  id_list=[]
  for security_group_name in sec_group_names:
    response = ec2.describe_security_groups(
    Filters=[
        dict(Name='group-name', Values=[security_group_name])
      ]
      )
    id_list.append(response['SecurityGroups'][0]['GroupId'])

  return id_list



def run_fargate_task(tasks, security_group_ids, cluster):

  """
  This will run a list of tasks with provided security group ids list attached to it in a given cluster
  """
  ecs = boto3.client('ecs')
  for task in tasks:
    try:
      run_task = ecs.run_task(
      cluster=cluster,
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

panelapp_security_groups = ['panelapp-fargate-panelapp-dev','aurora-dev']
panelapp_tasks = ['panelapp-migrate-panelapp-dev','panelapp-collectstatic-panelapp-dev','panelapp-loaddata-panelapp-dev','panelapp-createsuperuser-panelapp-dev']
panelapp_security_group_ids = get_security_id(panelapp_security_groups)
run_fargate_task(panelapp_tasks,panelapp_security_group_ids,'panelapp-cluster-dev')
