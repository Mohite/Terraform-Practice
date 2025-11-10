
# VPC CIDR
variable "vpc_cidr" {
  type        = string
  default     = ""
}

# Subnet CIDR
variable "subnet_cidr" {
  type        = string
  default     = ""
}
# EC2 AMI ID
variable "ami_id" {
  type        = string
  default     = ""
}

# Instance type
variable "instance_type" {
  type        = string
  default     = ""
}
