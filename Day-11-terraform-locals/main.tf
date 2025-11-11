locals {
  bucket-name = "${var.layer}-${var.env}-bucket-jay"
  region = "us-west-2"
  #provider = aws.oregon
}

resource "aws_s3_bucket" "test" {
    
    bucket = local.bucket-name
    region = local.region
    #provider = local.provider
    tags = {
        # Name = "${var.layer}-${var.env}-bucket-hyd"
        Name = local.bucket-name
        Environment = var.env
    }

}
