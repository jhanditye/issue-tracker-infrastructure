terraform {
  backend "s3" {
    bucket         = "track-it-all-tf-state"
    key            = "staging/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }
}

module "dev_module" {
  source = "../../modules/dev"
}