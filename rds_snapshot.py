#!/usr/local/bin/python3
import os
import argparse
import boto3
import datetime
import time

SNAPSHOT_NAME = datetime.datetime.now().strftime("%y-%m-%d-%H-%S")
INTERVAL_TYPE = 'days'
INTERVAL_NUM = 7
DB_Cluster_name = "aurora-prod"

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

args = parser.parse_args()

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
    print("Snapshot {} has been successfully shared with account - {}".format(SNAPSHOTNAME, account))


if __name__ == '__main__':
    try:
        if args.create:
            print("\n \n Executing the snapshot creation !!! \n")
            new_snapshot_name = rds_cluster_backup(DB_Cluster_name)

        if args.recycle:
            print("\n \n Executing the old snapshot deletion !!! \n")
            rds_cluster_snapshot_del(DB_Cluster_name)

        if args.account:
            if args.create:
                print("\n \n Executing the snapshot sharing !!! \n")
                rds_share_snapshot(new_snapshot_name, args.account)
            else:
                print("Please use -create option for the RDS Snapshot share")

        else:
            print("Please provide the variable -h for more help!")

    except (TypeError) as typeerror:

        print("\nSnapshot(s) has not been passed to the command\n")
        parser.print_help()

    except (IndexError) as error:

        print("\n The Snapshot has NOT been found \n")
