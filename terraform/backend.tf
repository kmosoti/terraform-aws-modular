terraform {
  backend "s3" {
    bucket         = "terraform-aws-modular-state"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
  }
}
