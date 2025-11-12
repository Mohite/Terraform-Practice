
#in foreach if any server is deleted then it will not shift the name of other server it will keep the name as it is
variable "env" {
    type = list(string)
    default = [ "dev","prod"]
  
}

resource "aws_instance" "name" {
    ami = "ami-07860a2d7eb515d9a"
    instance_type = "t3.micro"
    subnet_id              = "subnet-0cb5d0d3178d47036"  
    vpc_security_group_ids = ["sg-09a85f6ddcc7facaa"]  
    for_each = toset(var.env)
    #for_each = toset(var.env) 
    # tags = {
    #   Name = "dev"
    # }
  tags = {
      Name = each.value
    }
}