terraform {
  backend "s3" {
    bucket         = "my-terraform-statefilebucket"      # Replace with your actual S3 bucket name
    key            = "dev/terraform.tfstate"      # Path inside the bucket to store the state file
    region         = "us-east-1"                      # Region of your S3 bucket
                             
  }
}