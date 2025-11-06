
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
}


resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "Allow SSH"
  vpc_id      = aws_vpc.main.id

}

resource "aws_instance" "name" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  tags = {
    Name = "Terraform-EC2"
  }
}
