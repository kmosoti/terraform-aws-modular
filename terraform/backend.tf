terraform {
  backend "s3" {
    bucket         = "kzkenlabs-dev-terraform"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
  }
}
