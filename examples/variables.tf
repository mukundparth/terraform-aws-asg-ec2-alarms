variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "ap-south-1"
}

variable "custom_namespace" {
  type        = string
  description = "Custom namesspace to be used for CloudWatch custom metrics" 
  default     = "MyTestNamespace2"
