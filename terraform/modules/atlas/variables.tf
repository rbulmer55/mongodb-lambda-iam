
variable "mongodbatlas_project_id" {
  description = "Atlas Project Id"
  type        = string
}

variable "region" {
  description = "Atlas region"
  type        = string
  default     = "EU_WEST_1"
}

variable "cloud_provider" {
  description = "Atlas Cloud Provider"
  type        = string
  default     = "AWS"
}

