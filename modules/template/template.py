#!/usr/bin/env python

import decimal
import hashlib
import json
import sys
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


def create_or_update_tags(tag_key):
    """
      updates alarm tags in ASGs.

    """

    asgs = describe_auto_scaling_groups()

    for asg in asgs:
        response = autoscaling.create_or_update_tags(
           Tags=[
               {
                 'ResourceId': asg['AutoScalingGroupName'],
                 'ResourceType': 'auto-scaling-group',
                 'Key': tag_key,
                 'Value': '',
                 'PropagateAtLaunch': True
               },
           ]
        )
        if response['ResponseMetadata']['HTTPStatusCode'] != 200:
            raise Exception('ERROR: {}'.format(response))


# Parse the query.
query = json.load(sys.stdin)

# Build the JSON template.

boolean_keys = [
    'ActionsEnabled',
]
list_keys = [
    'AlarmActions',
    'Dimensions',
    'InsufficientDataActions',
    'OKActions',
]

alarm = {}
for key, value in query.items():

    if key in boolean_keys:
        value = value.lower() in ('1', 'true')
    elif key in list_keys:
        value = json.loads(value)

    if value:
        alarm[key] = value

content = json.dumps(alarm, indent=2, sort_keys=True)
etag = hashlib.md5(content.encode('utf-8')).hexdigest()

ALARM_NAME_PREFIX = 'InstanceAlarm:'
autoscaling = boto3.client('autoscaling')
tag_key = ALARM_NAME_PREFIX + etag

# Output the result to Terraform.
json.dump({
    'key': etag,
    'content': content,
    'etag': etag,
}, sys.stdout, indent=2)
sys.stdout.write('\n')


create_or_update_tags(tag_key)
