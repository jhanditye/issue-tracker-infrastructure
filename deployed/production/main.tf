terraform {
  backend "s3" {
    bucket = "track-it-all-tf-state"
    key    = "production/terraform.tfstate"
    region = "eu-west-2"
    dynamodb_table = "terraform-state-locking"
    encrypt = true
  }
}

module "setup_module"{
  source = "../../modules/hello-world"
}