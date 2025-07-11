
variable "ENVIRONMENT" {
  type        = string
  description = "Deployment environment: DEV, PRE, or PRD"
  validation {
    condition     = contains(["DEV", "TST", "PRE", "PRD"], upper(var.ENVIRONMENT))
    error_message = "ENVIRONMENT must be one of: DEV, PRE, PRD (case-insensitive)."
  }
}

variable "MDB_ATLAS_PROJECT_ID" {
  type        = string
  description = "MongoDB Atlas Project ID"
}

variable "MDB_ATLAS_CLUSTER_HOSTNAME" {
  type        = string
  description = "MongoDB Atlas Cluster hostname"
}

variable "MDB_ATLAS_PUBLIC_KEY" {
  type        = string
  description = "MongoDB Atlas Public Key"
}

variable "MDB_ATLAS_PRIVATE_KEY" {
  type        = string
  description = "MongoDB Atlas Private Key"
}
