#!/usr/local/bin/python3

# This is just an example to start one off task, has to be improved

import argparse
import boto3
from botocore.exceptions import ClientError

parser = argparse.ArgumentParser(description='Perform fargate tasks')

parser.add_argument('-sgs', help='name of the security groups with a space in between', nargs='+')

parser.add_argument('-tasks', help='name of the tasks with a space in between', nargs='+')

parser.add_argument('-cluster', help='name of the cluster to run the task', type=str)

parser.add_argument('-subnets', help='subnets ids to run the tasks with a space in between', nargs='+')

args = parser.parse_args()


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



def run_fargate_task(tasks, security_group_ids, cluster, subnets):

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
            'subnets': subnets,
            'securityGroups': security_group_ids,
            'assignPublicIp': 'ENABLED'
          }
      })
    except ClientError as e:
      print (e)

# panelapp_security_groups = ['panelapp-fargate-panelapp-dev','aurora-dev']
# panelapp_tasks = ['panelapp-migrate-panelapp-dev','panelapp-collectstatic-panelapp-dev','panelapp-loaddata-panelapp-dev','panelapp-createsuperuser-panelapp-dev']


panelapp_security_groups = args.sgs
panelapp_security_group_ids = get_security_id(args.sgs)
run_fargate_task(args.tasks, panelapp_security_group_ids, args.cluster, args.subnets)
