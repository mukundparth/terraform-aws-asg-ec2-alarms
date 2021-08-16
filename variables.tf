variable "name" {
  default = "asg-ec2-alarms"
}

variable "schedule" {
  default = "rate(5 minutes)"
}

variable "tags" {
  type    = map(string)
  default = null
}
