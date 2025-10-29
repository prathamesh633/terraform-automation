variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name to use for the AWS key pair"
  type        = string
  default     = "deployer-key"
}

variable "public_key" {
  description = "Your SSH public key material (ssh-rsa AAAA... or ssh-ed25519 AAAA...)"
  type        = string
  default     = ""
}

variable "allowed_cidr" {
  description = "CIDR allowed to SSH in (restrict this!)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "demo"
}
