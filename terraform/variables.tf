variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-2"
}

variable "ecs_cluster_name" {
  description = "The name of the ECS Cluster"
  type        = string
  default     = "warp-cluster"
}

variable "db_name" {
  description = "The name of the RDS database"
  type        = string
  default     = "warpdb"
}

variable "db_user" {
  description = "The username for the RDS database"
  type        = string
  default     = "warpuser"
}

variable "db_password" {
  description = "The password for the RDS database"
  type        = string
}

variable "db_instance_class" {
  description = "The instance class for the RDS database"
  type        = string
  default     = "db.t3.micro"
}

variable "warp_secret_key" {
  description = "The secret key for warp"
  type        = string
#  default     = "TF_VAR_warp_secret_key"
}

variable "warp_language_file" {
  description = "The secret key for warp"
  type        = string
  default     = "i18n/en.js"
}

variable "warp_database_init_script" {
  description = "The list of SQL scripts for initializing the database"
  type        = string
  default     = "[\"sql/schema.sql\", \"sql/sample_data.sql\"]"
}