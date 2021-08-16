provider "aws" {
  region = var.aws_region
}

resource "random_pet" "cwalarms" {
  prefix = "cw-alarms"
}

resource "aws_sns_topic" "cwalarms" {
  name = random_pet.cwalarms.id
}

module "instance_alarms" {
  source = "../"

  name = random_pet.cwalarms.id
}

##Default CloudWatch Alarms
module "asg_cpu_usage_alarm" {
  source = "../modules/template"

  bucket = module.instance_alarms.bucket

  AlarmDescription = "{{asg.AutoScalingGroupName}} is high on CPU usage"
  Namespace        = "AWS/EC2"
  MetricName       = "CPUUtilization"

  Dimensions = [
    {
      Name  = "AutoScalingGroupName"
      Value = "{{asg.AutoScalingGroupName}}"
    },
  ]

  Statistic          = "Average"
  ComparisonOperator = "GreaterThanOrEqualToThreshold"
  Threshold          = 80
  Period             = 300
  EvaluationPeriods  = 2

  OKActions = [
    aws_sns_topic.cwalarms.arn,
  ]

  AlarmActions = [
    aws_sns_topic.cwalarms.arn,
  ]

  InsufficientDataActions = [
    aws_sns_topic.cwalarms.arn,
  ]
}


module "cpu_credits_alarm" {
  source = "../modules/template"

  bucket = module.instance_alarms.bucket

  AlarmDescription = "{{instance.InstanceId}} is low on CPU credits"
  Namespace        = "AWS/EC2"
  MetricName       = "CPUCreditBalance"

  Dimensions = [
    {
      Name  = "AutoScalingGroupName"
      Value = "{{asg.AutoScalingGroupName}}"
    }
  ]

  Statistic          = "Average"
  ComparisonOperator = "LessThanOrEqualToThreshold"
  Threshold          = 20
  Period             = 60
  EvaluationPeriods  = 5

  OKActions = [
    aws_sns_topic.cwalarms.arn,
  ]

  AlarmActions = [
    aws_sns_topic.cwalarms.arn,
  ]

  InsufficientDataActions = [
    aws_sns_topic.cwalarms.arn,
  ]
}

##Custom Cloudwatch alarms
module "cpu_alarm" {
  source = "../modules/template"

  bucket = module.instance_alarms.bucket

  AlarmDescription = "{{instance.InstanceId}} CPU usage is high"
  Namespace        = var.custom_namespace
  MetricName       = "cpu_usage_idle"

  Dimensions = [
    {
      Name  = "AutoScalingGroupName"
      Value = "{{asg.AutoScalingGroupName}}"
    },
    {
      Name  = "InstanceId"
      Value = "{{instance.InstanceId}}"
    },
    {
      Name  = "cpu"
      Value = "cpu-total"
    }
  ]

  Statistic          = "Average"
  ComparisonOperator = "LessThanOrEqualToThreshold"
  Threshold          = 10
  Period             = 60
  EvaluationPeriods  = 5

  OKActions = [
    aws_sns_topic.cwalarms.arn,
  ]

  AlarmActions = [
    aws_sns_topic.cwalarms.arn,
  ]

  InsufficientDataActions = [
    aws_sns_topic.cwalarms.arn,
  ]
}

module "memory_alarm" {
  source = "../modules/template"

  bucket = module.instance_alarms.bucket

  AlarmDescription = "{{instance.InstanceId}} is low on memory"
  Namespace        = var.custom_namespace
  MetricName       = "mem_used_percent"

  Dimensions = [
    {
      Name  = "AutoScalingGroupName"
      Value = "{{asg.AutoScalingGroupName}}"
    },
    {
      Name  = "InstanceId"
      Value = "{{instance.InstanceId}}"
    },
  ]

  Statistic          = "Average"
  ComparisonOperator = "GreaterThanOrEqualToThreshold"
  Threshold          = 85
  Period             = 60
  EvaluationPeriods  = 5

  OKActions = [
    aws_sns_topic.cwalarms.arn,
  ]

  AlarmActions = [
    aws_sns_topic.cwalarms.arn,
  ]

  InsufficientDataActions = [
    aws_sns_topic.cwalarms.arn,
  ]
}

module "disk_alarm_root" {
  source = "../modules/template"

  bucket = module.instance_alarms.bucket

  AlarmDescription = "{{instance.InstanceId}} Disk usage for / is high"
  Namespace        = var.custom_namespace
  MetricName       = "disk_used_percent"

  Dimensions = [
    {
      Name  = "AutoScalingGroupName"
      Value = "{{asg.AutoScalingGroupName}}"
    },
    {
      Name  = "InstanceId"
      Value = "{{instance.InstanceId}}"
    },
    {
      Name  = "device",
      Value = "xvda"
    },
    {
      Name  = "fstype",
      Value = "xfs"
    },
    {
      Name  = "Path"
      Value = "/"
    }
  ]

  Statistic          = "Maximum"
  ComparisonOperator = "GreaterThanOrEqualToThreshold"
  Threshold          = 90
  Period             = 60
  EvaluationPeriods  = 5

  OKActions = [
    aws_sns_topic.cwalarms.arn,
  ]

  AlarmActions = [
    aws_sns_topic.cwalarms.arn,
  ]

  InsufficientDataActions = [
    aws_sns_topic.cwalarms.arn,
  ]
}
