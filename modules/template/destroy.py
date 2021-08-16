#!/usr/bin/env python
import boto3



def describe_auto_scaling_groups(**kwargs):
    """
    Returns Auto Scaling Groups.

    """

    paginator = autoscaling.get_paginator('describe_auto_scaling_groups')
    pages = paginator.paginate(**kwargs)
    for page in pages:
        if page['ResponseMetadata']['HTTPStatusCode'] != 200:
            raise Exception('ERROR: {}'.format(page))
        for asg in page['AutoScalingGroups']:
            yield asg


def delete_tags():
    """
      updates alarm tags in ASGs.

    """

    asgs = describe_auto_scaling_groups()

    for asg in asgs:
      tags = autoscaling.describe_tags()
      for tag in tags['Tags']:
          if 'InstanceAlarm:' in tag['Key']:
              response = autoscaling.delete_tags(
                 Tags=[
                     {
                       'ResourceId': asg['AutoScalingGroupName'],
                       'ResourceType': 'auto-scaling-group',
                       'Key': tag['Key'],
                       'Value': '',
                       'PropagateAtLaunch': True
                     },
                 ]
              )
              if response['ResponseMetadata']['HTTPStatusCode'] != 200:
                 raise Exception('ERROR: {}'.format(response))




autoscaling = boto3.client('autoscaling')

delete_tags()
