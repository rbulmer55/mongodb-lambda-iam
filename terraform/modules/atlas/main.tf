

resource "mongodbatlas_privatelink_endpoint" "aws" {
  project_id    = var.mongodbatlas_project_id
  provider_name = var.cloud_provider
  region        = var.region
}


