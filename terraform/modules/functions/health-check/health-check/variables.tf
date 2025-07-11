variable "function_name" {
  description = "The name of the function"
  type        = string
}

variable "private_subnet_id" {
  description = "Private Subnet id"
  type        = string
}

variable "vpc_id" {
  description = "VPC id"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "cluster_hostname" {
  description = "MDB Atlas Cluster hostname"
  type        = string
}

variable "access_role_arn" {
  description = "MDB Atlas IAM role ARN"
  type        = string
}

variable "atlas_security_group_id" {
  description = "MDB Atlas Security Group Id"
  type        = string
}

variable "tags" {
  description = "Tags passed into the resource"
  type        = map(string)
  default     = {}
}
