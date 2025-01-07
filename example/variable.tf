# [Mandatory Variables for which need to provide values]
variable "identifier_count" {
  type        = string
  description = "Enter your Environment identifier count"
  /* if you already have Dev environment i.e name usaedoraaird001 and you would like to provision second development
  environment then you should give 002 as a value */
}

variable "tags" {
  type        = map(string)
  description = "Enter Project Tagging Information"
}

variable "application_code" {
  type        = string
  description = "Application Code"
}

variable "region" {
  type        = string
  description = "Region in which you want to deploy the terraform resources"
}
variable "engine" {
  type        = string
  description = "Database Engine Type i.e SQLServer-se,mysql,postgresql.."
}
variable "engine_version" {
  type        = string
  description = "Database Engine Version"
}
variable "instance_class" {
  type        = string
  description = "Database instance class"
}
variable "allocated_storage" {
  type        = number
  description = "Enter database storage size"
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate"
  type        = list(string)
}
variable "db_subnet_group_name" {
  description = "Name of DB subnet group. DB instance will be created in the VPC associated with the DB subnet group. If unspecified, will be created in the default VPC"
  type        = string
}


## Optional variables for which application/migration team can provide values depends on application requirements
variable "iops" {
  description = "The amount of provisioned IOPS. Setting this implies a storage_type of 'io1'"
  type        = number
  default     = null
}

variable "max_allocated_storage" {
  type        = number
  description = "Maximum amount storage size till that storage can be auto increased"
}

/* Useful note for parameter_group_name variable
you can pass null value in parameter_group_name variable at the time of provisioning if you want the module to take the engine specific default.
But if you already attached the custom parameter group and want to change to the default one then you need to pass default parameter group name in this variable */

variable "parameter_group_name" {
  description = "Custom Name of the DB parameter group to associate if it is already exists other than default one, Pass null to allow to take engine specific default one. To create custom parameter group according to application requirement Pass true in create_parameter_group variable. Parameter group naming Must contain only letters, digits, or hyphens. Must start with a letter."
  type        = string
  default     = null
}

/* Useful note for option_group_name variable
you can pass null value in option_group_name variable at the time of provisioning if you want the module to take the engine specific default.
But if you already attached the custom option group and want to change to the default one then you need to pass default option group name in this variable */

variable "option_group_name" {
  description = "Name of the custom DB option group t]o associate if existing. pass null if you want module to take default option group engine specific. If you want to create new custom option group create by passing true in create_option_group variable. option group name Must contain only letters, digits, or hyphens. Must start with a letter."
  type        = string
  default     = null
}

## Create_parameter_group, parameter_group_family and parameter_group_parameters are mandatory variable if you want to create custom parameter group as per application requirements.
variable "create_parameter_group" {
  description = "Determines whether to create a parameter group or use existing"
  type        = bool
  default     = false
}
variable "parameter_group_family" { # mandatory variable when you want to create custom parameter group
  description = "The family of the rds parameter group"
  type        = string
  default     = null
}
variable "parameter_group_parameters" { # Mandatory variable when you want to create custom parameter group
  description = "value"
  type        = list(map(string))
  default     = []
}


## create_option_group are mandatory variable if you want to create custom option group as per application requirements.
variable "create_option_group" {
  description = "Determines whether to create a parameter group or use existing"
  type        = bool
  default     = false
}
variable "options" {
  description = "A list of Options to apply to create custom option group"
  type        = any
  default     = []
}
variable "major_engine_version" {
  description = "Specifies the major version of the engine that this option group should be associated with"
  type        = string
  default     = null
}

/* optional variable for KMS_key_id for Storage encryption of the rds.By default storage will be encrypted with the aws default aws/rds encryption key.
For use your own kms key enter kms_key_id for storage encryption */

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key. If creating an encrypted replica, set this to the destination KMS ARN. If storage_encrypted is set to true and kms_key_id is not specified the default KMS key created in your account will be used"
  type        = string
  default     = null
}

## For Standby DB Instance
variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type        = bool
  default     = false
}
variable "snapshot_identifier" {
  type        = string
  description = "Enter snapshot identifier if you want the db instance restoring from snapshot"
  default     = null
}
variable "character_set_name" {
  description = "The character set name to use for DB encoding in Oracle instances. This can't be changed. See Oracle Character Sets Supported in Amazon RDS and Collations and Character Sets for Microsoft SQL Server for more information. This can only be set on creation."
  type        = string
  default     = null
}
## By default delete protection is enabled
variable "deletion_protection" {
  description = "The database can't be deleted when this value is set to true. if you want to terminate the instance at that time first you need to disable deleteion_protetion by passing false in the .tfvars file"
  type        = bool
  default     = true
}
## performance insights is not supported as of now for MySQL DB Engine so pass false in application template for this variable when you provision MySQL DB Engine.
variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights are enabled"
  type        = bool
  default     = true
}
variable "master_username" {
  description = "Username for the master DB user"
  type        = string
  default     = null
}

