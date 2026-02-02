
terraform {
  backend "s3" {
    bucket         = "terraform-state-example4321"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
