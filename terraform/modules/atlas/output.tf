output "atlas_private_endpoint_service_name" {
  description = "Atlas Private Endpoint Service"
  value       = mongodbatlas_privatelink_endpoint.aws.endpoint_service_name
}

output "atlas_private_endpoint_link_id" {
  description = "Atlas Private Endpoint link Id"
  value       = mongodbatlas_privatelink_endpoint.aws.private_link_id
}
