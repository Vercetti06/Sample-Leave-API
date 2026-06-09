terraform{
 required_version =  ">= 1.13.3"
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = ">= 6.23.0"
        }
    }
  }
provider "aws" {
    region = "us-east-1"
} 

resource "aws_s3_bucket" "s3_bucket" {
bucket = "s3-backened-state"

  tags = {
    Name  = "s3-backened-state" 

  }
}
resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.s3_bucket.id
  
  versioning_configuration {
    status = "Enabled"
  }
}
