provider "aws" {}

terraform {
  backend "s3" {
    bucket = "mysrikanth"
    key = "eks/terraform.tfstate"
    region  =   "us-east-1"
  }
}