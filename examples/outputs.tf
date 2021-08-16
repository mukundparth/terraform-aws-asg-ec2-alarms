output "tag1" {
  value = "${module.asg_cpu_usage_alarm.tag}"
}

output "tag2" {
  value = "${module.cpu_credits_alarm.tag}"
}

output "tag3" {
  value = "${module.cpu_alarm.tag}"
}

output "tag4" {
  value = "${module.memory_alarm.tag}"
}

output "tag5" {
  value = "${module.disk_alarm_root.tag}"
}
