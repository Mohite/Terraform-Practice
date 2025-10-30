terraform {
  backend "s3" {
    bucket         = "my-terraform-statefilebucket"      # Replace with your actual S3 bucket name
    key            = "prod/terraform.tfstate"      # Path inside the bucket to store the state file
    region         = "us-east-1"                      # Region of your S3 bucket  
    use_lockfile=false    #will lock the file upto process finish     
    dynamodb_table = "vinu"        # DynamoDB table for state locking
    encrypt        = true                          # Encrypt state file in S3                    
  }
}