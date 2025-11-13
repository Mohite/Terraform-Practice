# Key Pair
resource "aws_key_pair" "example" {
  key_name   = "task-new"
  public_key = file("~/.ssh/id_ed25519.pub")
}


resource "aws_instance" "server" {
  ami                         = "ami-0261755bbcb8c4a84" # Ubuntu AMI
  instance_type               = "t3.micro"
  subnet_id              = "subnet-0cb5d0d3178d47036"  # 👈 specify subnet
  vpc_security_group_ids = ["sg-09a85f6ddcc7facaa"]  # 👈 use security group IDs, not names

  key_name                    = aws_key_pair.example.key_name
  tags = {
    Name = "Key-Management-Server"
  }
}