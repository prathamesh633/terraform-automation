variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "allowed_cidr" {
  description = "CIDR allowed to SSH in (restrict this!)"
  type        = string
  default     = "203.0.113.42/32"
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "demo"
}
