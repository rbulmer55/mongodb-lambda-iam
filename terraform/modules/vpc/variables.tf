variable "vpcName" {
  description = "The friendly vpc name of the resource"
  type        = string
}

variable "environment" {
  description = "The environment using the resource"
  type        = string
}

variable "tags" {
  description = "Tags passed into the resource"
  type        = map(string)
  default     = {}
}

variable "atlas_private_endpoint_service_name" {
  description = "The service name for MongoDB Atlas PrivateLink endpoint"
  type        = string
}

variable "atlas_private_endpoint_link_id" {
  description = "The link id for MongoDB Atlas PrivateLink endpoint"
  type        = string
}

variable "atlas_project_id" {
  description = "Atlas Project Id"
  type        = string
}
