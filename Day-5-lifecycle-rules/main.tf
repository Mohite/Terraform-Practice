resource "aws_instance" "dev" {
  ami="ami-0c02fb55956c7d316"
  instance_type="t3.micro"

  #lifecycle{
  #  create_before_destroy=true
  #}
#lifecycle{
  #  ignore_changes=[tags, ]
  #}
  lifecycle{
    prevent_destroy=true
  }

}