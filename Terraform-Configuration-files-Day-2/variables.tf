# AWS Region
variable "aws_region" {
  description = "AWS region where resources will be deployed"
  type        = string
  default     = ""
}

# VPC CIDR
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = ""
}

# Subnet CIDR
variable "subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = ""
}

# EC2 AMI ID
variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = ""
}

# Instance type
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}
