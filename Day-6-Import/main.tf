resource "aws_instance" "name" {
  ami="ami-0bdd88bd06d16ba03"
  instance_type="t3.micro"
  tags={
    Name="testing"
  }
}

#terraform import aws_instance.name i-0b4486befc1a57add this will create state file at current dir and once all resource added in main file then we add our own changes