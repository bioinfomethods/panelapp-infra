#!/usr/local/bin/python3

import os
import argparse
import boto3
from botocore.exceptions import ClientError, ParamValidationError

parser = argparse.ArgumentParser(description='Perform fargate tasks')

# parser.add_argument('-sgs', help='name of the security groups with a space in between', nargs='+', default=os.environ.get(''))

# parser.add_argument('-subnets', help='subnets ids to run the tasks with a space in between', nargs='+', default=os.environ.get(''))

parser.add_argument(
    '-tasks',
    help='name of the tasks with a space in between (Required)',
    nargs='+',
    default=os.environ.get(''))

parser.add_argument(
    '-cluster',
    help='name of the cluster to run the task (Required)',
    type=str,
    default=os.environ.get(''))

parser.add_argument('-command', help='command to override (Optional)')

parser.add_argument(
    '-services',
    help='services to get the subnets and security groups from them (Required)',
    nargs='+',
    default=os.environ.get(''))

parser.add_argument(
    '-panelapp',
    action='store_true',
    help='To initiate a task for panelapp cluster')

args = parser.parse_args()


def get_security_id(sec_group_names):
    """
  This returns the security group ids by providing the group names
  """

    ec2 = boto3.client('ec2')
    id_list = []
    for security_group_name in sec_group_names:
        response = ec2.describe_security_groups(
            Filters=[dict(Name='group-name', Values=[security_group_name])])

        id_list.append(response['SecurityGroups'][0]['GroupId'])

    return id_list


def get_container_name(task_def):
    ecs = boto3.client('ecs')

    container_name = ecs.describe_task_definition(taskDefinition=task_def)
    return container_name['taskDefinition']['containerDefinitions'][0]['name']


def run_fargate_task(
        tasks,
        security_group_ids,
        cluster,
        subnets,
        command,
):
    """
  This will run a list of tasks with provided security group ids list attached to it in a given cluster
  """

    ecs = boto3.client('ecs')
    for task in tasks:
        try:
            if args.command is None:
                ecs.run_task(
                    cluster=cluster,
                    launchType='FARGATE',
                    taskDefinition=task,
                    count=1,
                    platformVersion='LATEST',
                    networkConfiguration={
                        'awsvpcConfiguration': {
                            'subnets': subnets,
                            'securityGroups': security_group_ids,
                            'assignPublicIp': 'ENABLED'
                        }
                    },
                )
            else:

                container = get_container_name(''.join(args.tasks))

                ecs.run_task(
                    cluster=cluster,
                    launchType='FARGATE',
                    taskDefinition=task,
                    count=1,
                    platformVersion='LATEST',
                    networkConfiguration={
                        'awsvpcConfiguration': {
                            'subnets': subnets,
                            'securityGroups': security_group_ids,
                            'assignPublicIp': 'ENABLED'
                        }
                    },
                    overrides={
                        'containerOverrides': [{
                            'name': container,
                            'command': [command]
                        }]
                    },
                )

            if args.panelapp:
                print("\nTask "
                      '"{}"'
                      " Has been initiated in "
                      '"{}"'
                      " cluster\n".format(task,
                                          cluster.split('/')[1]))
            else:
                print("\nTask "
                      '"{}"'
                      " Has been initiated in "
                      '"{}"'
                      " cluster\n".format(task, cluster))
        except (ClientError, ParamValidationError) as e:

            if args.panelapp:

                print("\nTask "
                      '"{}"'
                      " initiation failed in "
                      '"{}"'
                      " cluster with the following error: ".format(
                          task,
                          cluster.split('/')[1])), print('{}'
                                                         '\n'.format(e))
                exit()

            else:

                print("\nTask "
                      '"{}"'
                      " initiation failed in "
                      '"{}"'
                      " cluster with the following error: ".format(
                          task, cluster)), print('{}'
                                                 '\n'.format(e))
                exit()


def get_subnet_security(cluster, services):
    try:
        ecs = boto3.client('ecs')
        response = ecs.describe_services(cluster=cluster, services=services)
        return (response['services'][0]['deployments'][0][
            'networkConfiguration']['awsvpcConfiguration']['securityGroups'],
                response['services'][0]['deployments'][0][
                    'networkConfiguration']['awsvpcConfiguration']['subnets'])
    except (ParamValidationError) as e:
        print("\n cluster or service has Not been passed to the command\n")
        parser.print_help()
        exit()
    except (ClientError) as clientError:

        print("\nCluster NOT found\n")
        exit()


def get_panelapp_cluster_service():
    ecs = boto3.client('ecs')

    cluster = ecs.list_clusters()

    panelapp_cluster = ''.join(
        [arn for arn in cluster['clusterArns'] if 'panelapp-cluster' in arn])

    panelapp_services = ecs.list_services(cluster=panelapp_cluster)

    return (panelapp_cluster, panelapp_services['serviceArns'])


if __name__ == '__main__':

    try:

        if args.panelapp:
            (panelapp_cluster,
             panelapp_service) = get_panelapp_cluster_service()
            (panelapp_security_groups, panelapp_subnets) = get_subnet_security(
                panelapp_cluster, panelapp_service)

            run_fargate_task(args.tasks, panelapp_security_groups,
                             panelapp_cluster, panelapp_subnets, args.command)
        else:
            (panelapp_security_groups, panelapp_subnets) = get_subnet_security(
                args.cluster, args.services)
            run_fargate_task(args.tasks, panelapp_security_groups,
                             args.cluster, panelapp_subnets, args.command)

    except (TypeError) as typeerror:

        print("\nTask(s) has not been passed to the command\n")
        parser.print_help()

    except (IndexError) as error:

        print("\n The service(s) has NOT been found \n")
