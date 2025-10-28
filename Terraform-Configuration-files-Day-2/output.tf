output "publicIp"{
   value=aws_instance.name.public_ip
}
output "privateIp"{
   value=aws_instance.name.private_ip
}