
#test deleted then test become prod 
# resource "aws_instance" "name" {
#     ami = "ami-07860a2d7eb515d9a"
#     instance_type = "t2.micro"
#     count = 2
#     # tags = {
#     #   Name = "dev"
#     # }
#   tags = {
#       Name = "dev-${count.index}"
#     }
# }

variable "env" {
    type = list(string)
    default = [ "dev","test","prod"]
  
}

resource "aws_instance" "name" {
    ami = "ami-07860a2d7eb515d9a"
    instance_type = "t3.micro"
    subnet_id              = "subnet-0cb5d0d3178d47036"  
    vpc_security_group_ids = ["sg-09a85f6ddcc7facaa"]  

    count = length(var.env)
  tags = {
      Name = var.env[count.index]
    }
}