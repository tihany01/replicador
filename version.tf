terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}  
terraform {
  backend "s3" {
    # Bucket S3
    bucket = "tihany-terraform-state"
    key    = "tareaReplicador.ftstate"
    region = "us-east-1"
    dynamodb_table = "tihany-terraform-state-tabla"
  }
}