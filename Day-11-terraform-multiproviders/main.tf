resource "aws_s3_bucket" "mybkt" {
  bucket = "my-unique-bucket-name-vinu"
}
resource "aws_s3_bucket" "mybkt2" {
  bucket = "my-unique-bucket-name-vinu-2"
  provider =   aws.west
  
}