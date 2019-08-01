#!/usr/local/bin/python3
import os
import argparse
import boto3
import datetime
import time
import sys

SNAPSHOT_NAME = datetime.datetime.now().strftime("%y-%m-%d-%H-%M-%S")
INTERVAL_TYPE = 'days'
INTERVAL_NUM = 14

parser = argparse.ArgumentParser(description='Perform snapshot tasks')

parser.add_argument(
    '-create',
    action='store_true',
    help='To initiate a snapshot for panelapp RDS cluster')

parser.add_argument(
    '-recycle',
    action='store_true',
    help='To Delete panelapp RDS cluster older snapshots')

parser.add_argument(
    '-account',
    help='Account we need to share the RDS snapshot',
    type=str,
    default=os.environ.get(''))

parser.add_argument(
    '-copy',
    help='Source snapshot ARN',
    type=str,
    default=os.environ.get(''))

parser.add_argument(
    '-checksnapshot',
    help='Please provide the hours to check whether any snapshots presents',
    type=int,
    default=os.environ.get(''))

args = parser.parse_args()


def get_db_cluster_name():

    print("Finding the DB name....")

    client = boto3.client('rds')
    response = client.describe_db_clusters()
    return response['DBClusters'][0]['DBClusterIdentifier']


def rds_cluster_backup(RDS_NAME):

    client = boto3.client('rds')
    print("Connecting to Cluster Database")
    SnapshotIdentifier = RDS_NAME + '-snap-' + SNAPSHOT_NAME
    print("Cluster Database snapshot backups stated... for " + SnapshotIdentifier)

    response = client.create_db_cluster_snapshot(
            DBClusterSnapshotIdentifier=SnapshotIdentifier,
            DBClusterIdentifier=RDS_NAME
    )

    time.sleep(5)

    snapshot_description = client.describe_db_cluster_snapshots(
        DBClusterIdentifier=RDS_NAME,
        DBClusterSnapshotIdentifier=SnapshotIdentifier
    )

    while snapshot_description['DBClusterSnapshots'][0]['Status'] != 'available':
        print("Still waiting for the DB Cluster snapshot for {} to complete!! [Status = {}]".format(RDS_NAME,snapshot_description['DBClusterSnapshots'][0]['Status']))
        time.sleep(10)
        snapshot_description = client.describe_db_cluster_snapshots(
            DBClusterIdentifier=RDS_NAME,
            DBClusterSnapshotIdentifier=SnapshotIdentifier
        )

    print("RDS Cluster Snapshot has been completed successfully for {} - [Status = {}]".format(RDS_NAME,snapshot_description['DBClusterSnapshots'][0]['Status']))
    return SnapshotIdentifier


def rds_cluster_snapshot_del(RDS_NAME):

    client = boto3.client('rds')
    print('Looking for items to delete - Retention ' + str(INTERVAL_NUM) + ' ' + INTERVAL_TYPE)

    for snapshot in client.describe_db_cluster_snapshots(DBClusterIdentifier=RDS_NAME, SnapshotType="manual")['DBClusterSnapshots']:
        create_ts = snapshot['SnapshotCreateTime'].replace(tzinfo=None)
        if create_ts < datetime.datetime.now() - datetime.timedelta(**{INTERVAL_TYPE: INTERVAL_NUM}):
            print("Deleting snapshot id:{}".format(snapshot['DBClusterSnapshotIdentifier']))
            client.delete_db_cluster_snapshot(
                 DBClusterSnapshotIdentifier=snapshot['DBClusterSnapshotIdentifier']
            )

    my_response = "Completed snapshot copy and purge for RDS database..."
    return my_response


def rds_share_snapshot(SNAPSHOTNAME, account):

    client = boto3.client('rds')
    print("Sharing the snapshot to other account {}".format(account))

    response = client.modify_db_cluster_snapshot_attribute(
        DBClusterSnapshotIdentifier=SNAPSHOTNAME,
        AttributeName='restore',
        ValuesToAdd=[account]
    )

    snapshot_description = client.describe_db_cluster_snapshots(
        DBClusterSnapshotIdentifier=SNAPSHOTNAME
    )

    print("Snapshot {} has been successfully shared with account - {}".format(SNAPSHOTNAME, account))
    print("\nPlease use this snapshort arn name for the snapshot copy in account {} - {}\n".format(account, snapshot_description['DBClusterSnapshots'][0]['DBClusterSnapshotArn']))
    with open(".snapshot_name.txt", "w") as source_name:
        source_name.write(snapshot_description['DBClusterSnapshots'][0]['DBClusterSnapshotArn'])
    return snapshot_description['DBClusterSnapshots'][0]['DBClusterSnapshotArn']


def rds_copy_snapshot(sourcesnap):

    # We need Target KMS Key ID to copy the snapshot from Source account tp Target Account.
    print("\n Finding the KMS target Key ID.....\n")
    kms = boto3.client('kms')
    targetsnap = "local-" + sourcesnap.split(":")[-1]
    keylist = kms.list_aliases()
    for key in keylist["Aliases"]:
        if "rds-site" in key['AliasName']:
            targetkeyalias = key['AliasName']
            targetkeyid=str(key['TargetKeyId'])
    print("\n KMS key Alias Name: {} and Key IS: {} will be used.\n".format(targetkeyalias, targetkeyid))

    # Copy Snapshot from source to target account
    client = boto3.client('rds')
    response = client.copy_db_cluster_snapshot(
        SourceDBClusterSnapshotIdentifier=sourcesnap,
        TargetDBClusterSnapshotIdentifier=targetsnap,
        KmsKeyId=targetkeyid
    )
    time.sleep(5)

    # Checks the copy has been completed before proceeding to delete the Aurora DB instances.
    snapshot_description = client.describe_db_cluster_snapshots(
        DBClusterSnapshotIdentifier=targetsnap
    )
    while snapshot_description['DBClusterSnapshots'][0]['Status'] != 'available':
        print\
            ("Still copying snapshot from {} to {}!! [ Status = {} ]".format(sourcesnap, targetsnap, snapshot_description['DBClusterSnapshots'][0]['Status']))
        time.sleep(10)
        snapshot_description = client.describe_db_cluster_snapshots(
            DBClusterSnapshotIdentifier=targetsnap
        )
    print("\nRDS Cluster Snapshot copy has been completed successfully from {} to {} - [ Status = {} ]\n".format(sourcesnap,targetsnap,snapshot_description['DBClusterSnapshots'][0]['Status']))
    snapshot_description = client.describe_db_cluster_snapshots(
        DBClusterSnapshotIdentifier=targetsnap
    )
    return snapshot_description['DBClusterSnapshots'][0]['DBClusterSnapshotArn']


def check_snapshot(rds_cluster_name, interval):
    client = boto3.client('rds')
    print("Looking for the snapshots available within the last {} hours".format(interval))
    count = 0

    for snapshot in client.describe_db_cluster_snapshots(DBClusterIdentifier=rds_cluster_name, SnapshotType="manual")['DBClusterSnapshots']:
        create_ts = snapshot['SnapshotCreateTime'].replace(tzinfo=None)
        if create_ts > datetime.datetime.now() - datetime.timedelta(**{"hours": interval}):
            print("Snapshots available - {}".format(snapshot['DBClusterSnapshotIdentifier']))
            count = count + 1
    if count == 0:
        sys.stderr.write("\nError!: No snapshot found \n\n")
        sys.exit(20)


if __name__ == '__main__':
    try:
        if args.create:
            print("\n \n Executing the snapshot creation !!! \n")
            DB_Cluster_name = get_db_cluster_name()
            new_snapshot_name = rds_cluster_backup(DB_Cluster_name)

        if args.recycle:
            print("\n \n Executing the old snapshot deletion !!! \n")
            DB_Cluster_name = get_db_cluster_name()
            rds_cluster_snapshot_del(DB_Cluster_name)

        if args.account:
            if args.create:
                print("\n \n Executing the snapshot sharing !!! \n")
                source_snapshot_arn = rds_share_snapshot(new_snapshot_name, args.account)
            else:
                print("Please use -create option for the RDS Snapshot share")

        if args.copy:
            if not args.create:
                rds_copy_snapshot(args.copy)

            else:
                print("Create and Copy can't be used at the same time ")

    except (TypeError) as typeerror:

        print("\nSnapshot(s) has not been passed to the command\n")
        parser.print_help()

    except (IndexError) as error:

        print("\n The Snapshot has NOT been found \n")
