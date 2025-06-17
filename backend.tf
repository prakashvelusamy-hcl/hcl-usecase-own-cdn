terraform {
  backend "s3" {
    bucket         = "aws-state-s3"
    key            = "hcl-usecase-own/terraform.tfstate"
    #profile        = "devops"
    region         = "ap-south-1"                
    encrypt        = true                         
  }
}