provider "aws" {
  region = "eu-west-1"
}

provider "mongodbatlas" {
  public_key  = var.MDB_ATLAS_PUBLIC_KEY
  private_key = var.MDB_ATLAS_PRIVATE_KEY
}
