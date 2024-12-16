variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "subnet_cidrs" {
  description = "Subnet CIDR blocks"
  type        = map(string)
}

variable "aws_region" {
  description = "The AWS region"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  sensitive   = true
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
}

# S3 Backend Variables
variable "s3_bucket_name" {
  description = "Name of the S3 bucket for the backend"
  type        = string
}

variable "s3_bucket_key" {
  description = "Key for the state file in the S3 bucket"
  type        = string
}

variable "s3_region" {
  description = "AWS region for the S3 bucket"
  type        = string
}

variable "dynamodb_table" {
  description = "DynamoDB table for the Terraform lock"
  type        = string
}

# Ansible Variables
variable "ansible_inventory_path" {
  description = "Path to the Ansible inventory file"
  type        = string
}

variable "terraform_log_path" {
  description = "Path to the Terraform debug log"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key file"
  type        = string
}

variable "ansible_user" {
  description = "User for Ansible SSH access"
  type        = string
  default     = "ubuntu"
}
