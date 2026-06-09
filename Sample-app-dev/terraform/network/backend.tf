terraform{
backend "s3"{
bucket= "s3-backend-state"
key="api-leave/terraform.tfstate"
use_lockfile=true
encrypt=true
region="us-east-1"

}
required_version=">= 1.13.3"
required_providers {
aws = {
source="hashicorp/aws"
version=">=6.23.0"
}
}
}
provider "aws" {
region="us-east-1"
}
