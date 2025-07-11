

module "mdb_atlas" {
  providers = {
    mongodbatlas = mongodbatlas
  }
  source                  = "../../modules/atlas"
  mongodbatlas_project_id = var.MDB_ATLAS_PROJECT_ID

  depends_on = []
}


module "health_check_vpc" {
  source                              = "../../modules/vpc"
  environment                         = var.ENVIRONMENT
  vpcName                             = "${local.project_name}-vpc"
  atlas_private_endpoint_service_name = module.mdb_atlas.atlas_private_endpoint_service_name
  atlas_private_endpoint_link_id      = module.mdb_atlas.atlas_private_endpoint_link_id
  atlas_project_id                    = var.MDB_ATLAS_PROJECT_ID

  tags = local.common_tags

  depends_on = [module.mdb_atlas]
}


module "mdb_access_role" {
  source = "../../modules/role"
  tags   = local.common_tags
}


module "health_check_function" {
  source                  = "../../modules/functions/health-check/health-check"
  function_name           = "${local.project_name}-${var.ENVIRONMENT}-HealthCheck"
  vpc_cidr                = module.health_check_vpc.vpc_cidr
  vpc_id                  = module.health_check_vpc.vpc_id
  private_subnet_id       = module.health_check_vpc.vpc_prv_subnet_id
  atlas_security_group_id = module.health_check_vpc.atlas_security_group_id
  cluster_hostname        = var.MDB_ATLAS_CLUSTER_HOSTNAME
  access_role_arn         = module.mdb_access_role.role_arn
  tags                    = local.common_tags

  depends_on = [
    module.health_check_vpc,
    module.mdb_access_role
  ]
}


module "api_gateway" {
  source                   = "../../modules/api-gateway"
  api_name                 = "${local.project_name}-${var.ENVIRONMENT}-API"
  api_description          = "API for health check operations"
  stage_name               = lower(var.ENVIRONMENT)
  tags                     = local.common_tags
  health_check_lambda_arn  = module.health_check_function.invoke_arn
  health_check_lambda_name = module.health_check_function.function_name


  depends_on = [module.health_check_function]
}


