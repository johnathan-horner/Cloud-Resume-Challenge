terraform {
  # State lives in a private, versioned, encrypted S3 bucket with S3-native locking.
  # Never commit terraform.tfstate; it is in .gitignore.
  backend "s3" {
    bucket       = "jhorner-terraform-state-194959907772"
    key          = "cloud-resume/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.100.0"
    }
  }
}
provider "aws" {
  profile ="default"
  region = "us-east-1"
}