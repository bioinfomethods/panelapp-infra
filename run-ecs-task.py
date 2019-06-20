#!/usr/local/bin/python3

# This is just an example to start one off task, has to be improved

import os
import sys
import argparse
import boto3
from botocore.exceptions import ClientError, ParamValidationError

parser = argparse.ArgumentParser(description='Perform fargate tasks')

parser.add_argument('-sgs', help='name of the security groups with a space in between', nargs='+', default=os.environ.get(''))

parser.add_argument('-tasks', help='name of the tasks with a space in between', nargs='+', default=os.environ.get(''))

parser.add_argument('-cluster', help='name of the cluster to run the task', type=str, default=os.environ.get(''))

parser.add_argument('-subnets', help='subnets ids to run the tasks with a space in between', nargs='+', default=os.environ.get(''))

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

      print("\nTask " '"{}"' " Has been initiated in " '"{}"' " cluster\n".format(task,cluster))

    except (ClientError,ParamValidationError) as e:
      print("\nTask " '"{}"' " initiation failed in " '"{}"' " cluster with the following error: ".format(task,cluster)),print( '{}' '\n'.format(e))
    
# panelapp_security_groups = ['panelapp-fargate-panelapp-dev','aurora-dev']
# panelapp_tasks = ['panelapp-migrate-panelapp-dev','panelapp-collectstatic-panelapp-dev','panelapp-loaddata-panelapp-dev','panelapp-createsuperuser-panelapp-dev']

try:
  panelapp_security_groups = args.sgs
  panelapp_security_group_ids = get_security_id(args.sgs)
  run_fargate_task(args.tasks, panelapp_security_group_ids, args.cluster, args.subnets)
except (IndexError, TypeError) as error:
  print('\nIt is likely that one or some of the arguments has not been defined or provided incorrectly, see the error and the usage below\n'),print(error),parser.print_help()


