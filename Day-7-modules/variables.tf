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
