
#terraform taint aws_instance.terraform_server command used to mark resoure as tainted so that it will be deleted  and recreate 
resource "aws_instance" "terraform_server" {
  ami="ami-0bdd88bd06d16ba03"
  instance_type = "t3.micro"
  subnet_id              = "subnet-0cb5d0d3178d47036"  # 👈 specify subnet
  vpc_security_group_ids = ["sg-09a85f6ddcc7facaa"]  # 👈 use security group IDs, not names

  tags = {
    name="terra-server"
  }
}

