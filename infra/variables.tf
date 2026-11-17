variable "region" {
  description = "华为云区域"
  type        = string
  default     = "cn-north-4"
}

variable "project_id" {
  description = "项目ID"
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "VPC 网段"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "子网网段"
  type        = string
  default     = "10.0.1.0/24"
}

variable "gaussdb_instance_name" {
  description = "GaussDB-Mongo 实例名称"
  type        = string
  default     = "startup-kit-mongo"
}

variable "gaussdb_password" {
  description = "GaussDB-Mongo 数据库密码"
  type        = string
  sensitive   = true
  default     = "ChangeMe123!"
}

variable "apig_name" {
  description = "APIG 实例名称"
  type        = string
  default     = "startup-kit-todo-api"
}

variable "enable_managed_database" {
  description = "是否启用 GaussDB-Mongo 实例（付费，默认关闭）"
  type        = bool
  default     = false
}

variable "enable_apig" {
  description = "是否启用 APIG 实例（付费，默认关闭）"
  type        = bool
  default     = false
}
