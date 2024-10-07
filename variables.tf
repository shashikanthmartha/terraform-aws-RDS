variable "env" {
  description = "The environment in which the resources are deployed"   
  type = string
}
variable "rds_privatesubnets" {
  description = "The private subnets in which the RDS instance will be deployed"
  type = list(string)
}

variable "rds_allocated_storage" {
  description = "The allocated storage for the RDS instance"
  type        = number
}

variable "rds_storage_type" {
  description = "The storage type for the RDS instance"
  type        = string
}

variable "rds_engine" {
  description = "The database engine for the RDS instance"
  type        = string
}

variable "rds_engine_version" {
  description = "The engine version for the RDS instance"
  type        = string
}

variable "rds_instance_class" {
  description = "The instance class for the RDS instance"
  type        = string
}

variable "rds_multi_az" {
  description = "Whether the RDS instance is multi-AZ"
  type        = bool
}
  
variable "rds_publicly_accessible" {
  description = "Whether the RDS instance is publicly accessible"
  type        = bool
}
variable "rds_username" {
  description = "The username for the RDS instance"
  type        = string  
  
}
variable "rds_backup_retention_period" {
  description = "The backup retention period for the RDS instance"
  type        = number
}
variable "rds_storage_encrypted" {
  description = "Whether the RDS instance storage is encrypted"
  type        = bool
  
}
variable "rds_sg_ingress_rules" {
  type = any
}
variable "rds_sg_egress_rules" {
  type = any
}
variable "vpc_id" {
  description = "The VPC ID"
  type = string
  
}