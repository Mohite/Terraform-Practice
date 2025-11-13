resource "aws_instance" "name" { 
     subnet_id              = "subnet-0cb5d0d3178d47036"  # 👈 specify subnet
     vpc_security_group_ids = ["sg-09a85f6ddcc7facaa"]  # 👈 use security group IDs, not names

    instance_type = var.type
     ami = var.ami_id
     user_data = file("test.sh")  # calling test.sh from current directory by using file fucntion 
     tags = {
       Name = "dev"
     }


  
}