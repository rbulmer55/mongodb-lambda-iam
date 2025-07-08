locals {
  project_name = "HealthCheckService"
  common_tags = {
    Project     = local.project_name
    Environment = var.ENVIRONMENT
    Owner       = "Robert.Bulmer"
  }
}
