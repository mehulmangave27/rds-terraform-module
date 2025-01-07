variable "create" {
  type        = bool
  description = "Whether to create this resource or not?"
  default     = true
}

variable "region" {
  type        = string
  description = "AWS Region"
}

variable "application_code" {
  type        = string
  description = "Application Code"
  validation {
    condition     = can(length(var.application_code)) ? length(var.application_code) == 3 : false
    error_message = "Application Code value is required, It cannot be null or empty. It should be 3 letters."
  }
  /*cf-ui-field = "yes"
  display-name = "Application Code"
  view = "mandatory"
  sample = "RMS"
  */
}
variable "environment" {
  type        = string
  description = "Environment value"
}
variable "identifier_count" {
  type        = string
  description = "DB Identifier Count"
  default     = "001"
  /*cf-ui-field = "yes"
  display-name = "RDS DB Identifier Count"
  view = "mandatory"
  sample = "001"
  */
}


variable "engine" {
  description = "The database engine to use"
  type        = string
  default     = null
  /*cf-ui-field = "yes"
  display-name = "RDS DB Engine"
  view = "mandatory"
  sample = "sqlserver-se"
  */
}

variable "engine_version" {
  description = "The engine version to use"
  type        = string
  default     = null
  /*cf-ui-field = "yes"
  display-name = "RDS DB Engine Version"
  view = "mandatory"
  sample = "15.00.4236.7.v1"
  */
}

variable "instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
  default     = null
  /*cf-ui-field = "yes"
  display-name = "RDS DB Instance Class"
  view = "mandatory"
  sample = "db.m5.xlarge"
  */
}

variable "allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = string
  default     = null
  /*cf-ui-field = "yes"
  display-name = "RDS DB Allocated Storage"
  view = "mandatory"
  sample = "1000"
  */
}

variable "max_allocated_storage" {
  description = "Specifies the value for Storage Autoscaling"
  type        = number
  default     = null
  /*cf-ui-field = "yes"
  display-name = "RDS DB Max Allocated Storage"
  view = "optional"
  sample = "1500"
  */
}

/* restriciting gp2 storage type as per syngenta standard, default storage will be gp3 */
variable "storage_type" {
  description = "One of 'standard' (magnetic), 'gp3' (general purpose SSD), or 'io1' (provisioned IOPS SSD). The default is 'io1' if iops is specified, 'standard' if not. Note that this behaviour is different from the AWS web console, where the default is 'gp3'."
  type        = string
  default     = "gp3"
}

variable "storage_encrypted" {
  description = "Specifies whether the DB instance is encrypted"
  type        = bool
  default     = true
  /*cf-ui-field = "yes"
  display-name = "DB Storage Encryption"
  view = "optional"
  sample = "true"
  */
}

variable "master_username" {
  description = "Username for the master DB user"
  type        = string
  default     = null
}

variable "password" {
  description = "Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file"
  type        = string
  default     = null
  sensitive   = true
}

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type        = bool
  default     = false
  /*cf-ui-field = "yes"
  display-name = "RDS DB Multi AZ"
  view = "optional"
  sample = false
  */
}

variable "character_set_name" {
  description = "The character set name to use for DB encoding in Oracle instances. This can't be changed. See Oracle Character Sets Supported in Amazon RDS and Collations and Character Sets for Microsoft SQL Server for more information. This can only be set on creation."
  type        = string
  default     = null
}

variable "db_subnet_group_name" {
  description = "Name of DB subnet group. DB instance will be created in the VPC associated with the DB subnet group. If unspecified, will be created in the default VPC"
  type        = string
  validation {
    condition     = length(var.db_subnet_group_name) > 0 && lower(var.db_subnet_group_name) != null ? true : false
    error_message = "Subnet group Name is mandatory, It can't be null or empty."
  }
  /*cf-ui-field = "yes"
  display-name = "RDS DB Subnet Group Name"
  view = "mandatory"
  sample = "ams-application-vpc-vpc-cpr-ppo-applicationsrdsdbsubnetgroup-fh4gvjjowho1"
  */
}

variable "tags" {
  description = "A map of mandatory tags to add to all resources"
  type        = map(string)
  validation {
    condition     = can(length(var.tags["BusinessFunction"])) ? length(var.tags["BusinessFunction"]) >= 2 : false
    error_message = "BusinessFunction tag is required, It can't be null or Empty and minimum length should be 2."
  }

  validation {
    condition = can(length(var.tags["OwnerEmail"])) ? (length(var.tags["OwnerEmail"]) >= 2) && (length(regexall("^[\\w-._]+@syngenta.+[a-z]{2,4}$", var.tags["OwnerEmail"])) > 0) : false
    //&& can(length(var.tags["OwnerEmail"] >= 2)) //&& can(regex("^[a-z0-9]+@syngenta.+[a-z]{2,4}$", var.tags["OwnerEmail"]))
    error_message = "OwnerEmail tag is required, It can't be null or Empty and should be syngenta mail id."
  }

  validation {
    condition = can(length(var.tags["ContactEmail"])) ? (length(var.tags["ContactEmail"]) >= 2) && (length(regexall("^[\\w-._]+@syngenta.+[a-z]{2,4}$", var.tags["ContactEmail"])) > 0) : false
    //&& can(length(var.tags["OwnerEmail"] >= 2)) //&& can(regex("^[a-z0-9]+@syngenta.+[a-z]{2,4}$", var.tags["OwnerEmail"]))
    error_message = "ContactEmail tag is required, It can't be null or Empty and should be syngenta mail id."
  }

  validation {
    condition     = can(length(var.tags["Application"])) ? length(var.tags["Application"]) >= 2 : false
    error_message = "Application tag is required, It can't be null or Empty."
  }

  validation {
    condition     = can(length(var.tags["Environment"])) ? length(var.tags["Environment"]) >= 2 && (length(regexall("^(Development|Test|Stage|Production)$", var.tags["Environment"])) > 0) : false
    error_message = "Environment tag is required, It can't be null or Empty! Correct values are Development or Test or Stage or Production."
  }

  validation {
    condition     = can(length(var.tags["Platform"])) ? length(var.tags["Platform"]) >= 2 : false
    error_message = "Platform tag is required, It can't be null or Empty."
  }

  validation {
    condition     = can(length(var.tags["CostCenter"])) ? length(var.tags["CostCenter"]) >= 2 : false
    error_message = "CostCenter tag is required, It can't be null or Empty."
  }
  validation {
    condition     = can(length(var.tags["Purpose"])) ? length(var.tags["Purpose"]) >= 2 : false
    error_message = "Purpose tag is required, It can't be null or Empty."
  }
  validation {
    condition     = can(length(var.tags["CreatedByEmail"])) ? (length(var.tags["CreatedByEmail"]) >= 2) && (length(regexall("^[\\w-._]+@syngenta.+[a-z]{2,4}$", var.tags["CreatedByEmail"])) > 0) : false
    error_message = "CreatedByEmail tag is required, It can't be null or Empty and should be syngenta mail id."
  }

  /*cf-ui-field = "yes"
  display-name = "Tags"
  view = "mandatory"
  sample = [
							{
							  BusinessFunction = "<business_function>"
                OwnerEmail       = "<owner_email>"
                ContactEmail     = "<contact_email>"
                Platform         = "<platform>"
                CostCenter       = "<cost_center>"
                Application      = "<application>"
                Purpose          = "<purpose>"
                Environment      = "<environment>"
                CreatedByEmail   = "<created_by_email>"
							}
						  ]*/

}

variable "db_name" {
  description = "The DB name to create. If omitted, no database is created initially"
  type        = string
  default     = null
}

variable "domain" {
  description = "The ID of the Directory Service Active Directory domain to create the instance in"
  type        = string
  default     = null
}

variable "domain_iam_role_name" {
  description = "(Required if domain is provided) The name of the IAM role to be used when making API calls to the Directory Service"
  type        = string
  default     = null
}

variable "iam_database_authentication_enabled" {
  description = "Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled"
  type        = bool
  default     = false
}


variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate"
  type        = list(string)
  validation {
    condition     = length(var.vpc_security_group_ids) > 0 ? true : false
    error_message = "Security group IDs is mandatory, It can't be null or empty."
  }
  /*cf-ui-field = "yes"
  display-name = "Security Group Ids"
  view = "mandatory"
  sample = ["sg-022bf10ce6cd76bcd", "sg-0c1c37c068bbe8604"]
  */
}


variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted. If true is specified, no DBSnapshot is created. If false is specified, a DB snapshot is created before the DB instance is deleted"
  type        = bool
  default     = false
}

variable "parameter_group_name" {
  description = "Name of the DB parameter group to associate. Must contain only letters, digits, or hyphens. Must start with a letter."
  type        = string
  default     = null
}

variable "option_group_name" {
  description = "Name of the DB option group to associate. Must contain only letters, digits, or hyphens. Must start with a letter."
  type        = string
  default     = null
}

## optional variable to create custom parameter group and option group

# Variable for Custom Parameter group
variable "create_parameter_group" {
  description = "Determines whether to create a parameter group or use existing"
  type        = bool
  default     = false
}
variable "parameter_group_description" {
  description = "The description of the RDS parameter group. Defaults to `Managed by Terraform`"
  type        = string
  default     = "Custom parameter group created and Managed by Terraform"
}

variable "parameter_group_family" {
  description = "The family of the rds parameter group"
  type        = string
  default     = ""
}

variable "parameter_group_parameters" {
  description = "value"
  type        = list(map(string))
  default     = []
}
## Variable for Custom option group
variable "create_option_group" {
  description = "Determines whether to create a parameter group or use existing"
  type        = bool
  default     = false
}
variable "option_group_description" {
  description = "The description of the RDS option group. Defaults to `Managed by Terraform`"
  type        = string
  default     = "Custom option group created and Managed by Terraform"
}
variable "use_name_prefix" {
  description = "Determines whether to use `name` as is or create a unique name beginning with `name` as the specified prefix"
  type        = bool
  default     = true
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
variable "timeouts" {
  description = "Define maximum timeout for deletion of `aws_db_option_group` resource"
  type        = map(string)
  default = {
    create  = "10m"
    update  = "10m"
    delete  = "10m"
    default = "10m"
  }
}

## KMS key For Storage encryption. It is recommend to use the aws default encryption key by passing null.
variable "kms_key_id" {
  description = "The ARN for the KMS encryption key. If creating an encrypted replica, set this to the destination KMS ARN. If storage_encrypted is set to true and kms_key_id is not specified the default KMS key created in your account will be used"
  type        = string
  default     = null
}

variable "availability_zone" {
  description = "The Availability Zone of the RDS instance"
  type        = string
  default     = null
}

variable "iops" {
  description = "The amount of provisioned IOPS. Setting this implies a storage_type of 'io1'"
  type        = number
  default     = null
}

variable "publicly_accessible" {
  description = "Bool to control if instance is publicly accessible"
  type        = bool
  default     = false
  validation {
    condition     = (length(regexall("^false$", var.publicly_accessible)) > 0)
    error_message = "Database cant be publicly accessible,please set the flag to false."
  }
}

variable "ca_cert_identifier" {
  description = "Specifies the identifier of the CA certificate for the DB instance"
  type        = string
  default     = null
}

variable "allow_major_version_upgrade" {
  description = "Indicates that major version upgrades are allowed. Changing this parameter does not result in an outage and the change is asynchronously applied as soon as possible"
  type        = bool
  default     = true
}

variable "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window"
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Specifies whether any database modifications are applied immediately, or during the next maintenance window"
  type        = bool
  default     = true
}

variable "maintenance_window" {
  description = "The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi'. Eg: 'Mon:00:00-Mon:03:00'"
  type        = string
  default     = null
}

variable "snapshot_identifier" {
  description = "Specifies whether or not to create this database from a snapshot. This correlates to the snapshot ID you'd find in the RDS console, e.g: rds:production-2015-06-26-06-05."
  type        = string
  default     = null
}

variable "copy_tags_to_snapshot" {
  description = "On delete, copy all Instance tags to the final snapshot"
  type        = bool
  default     = true
}

## Enable Performance Insights by default for all rds for 7 days as it is free-tier for 7 days
variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights are enabled"
  type        = bool
  default     = true
}
variable "performance_insights_retention_period" {
  description = "The amount of time in days to retain Performance Insights data. Either 7 (7 days) or 731 (2 years)."
  type        = number
  default     = 7
}
variable "performance_insights_kms_key_id" {
  description = "The ARN for the KMS key to encrypt Performance Insights data."
  type        = string
  default     = null
}

variable "replicate_source_db" {
  description = "Specifies that this resource is a Replicate database, and to use this value as the source database. This correlates to the identifier of another Amazon RDS Database to replicate."
  type        = string
  default     = null
}

variable "replica_mode" {
  description = "Specifies whether the replica is in either mounted or open-read-only mode. This attribute is only supported by Oracle instances. Oracle replicas operate in open-read-only mode unless otherwise specified"
  type        = string
  default     = null
}

variable "backup_window" {
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled. Example: '09:46-10:16'. Must not overlap with maintenance_window"
  type        = string
  default     = null
}

variable "monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60."
  type        = number
  default     = 0
}

variable "create_monitoring_role" {
  description = "Create IAM role with a defined name that permits RDS to send enhanced monitoring metrics to CloudWatch Logs."
  type        = bool
  default     = false
}

variable "monitoring_role_name" {
  description = "Name of the IAM role which will be created when create_monitoring_role is enabled."
  type        = string
  default     = "rds-monitoring-role"
}

variable "monitoring_role_arn" {
  description = "The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. Must be specified if monitoring_interval is non-zero."
  type        = string
  default     = null
}

variable "monitoring_role_use_name_prefix" {
  description = "Determines whether to use `monitoring_role_name` as is or create a unique identifier beginning with `monitoring_role_name` as the specified prefix"
  type        = bool
  default     = false
}

variable "monitoring_role_description" {
  description = "Description of the monitoring IAM role"
  type        = string
  default     = null
}

variable "timezone" {
  description = "Time zone of the DB instance. timezone is currently only supported by Microsoft SQL Server. The timezone can only be set on creation. See MSSQL User Guide for more information."
  type        = string
  default     = null
}

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to enable for exporting to CloudWatch logs. If omitted, no logs will be exported. Valid values (depending on engine): alert, audit, error, general, listener, slowquery, trace, postgresql (PostgreSQL), upgrade (PostgreSQL)."
  type        = list(string)
  default     = []
}

## By default delete protection is enabled
variable "deletion_protection" {
  description = "The database can't be deleted when this value is set to true."
  type        = bool
  default     = true
  /*cf-ui-field = "yes"
  display-name = "RDS DB Deletion Protection
  view = "optional"
  sample = true
  */
}

variable "delete_automated_backups" {
  description = "Specifies whether to remove automated backups immediately after the DB instance is deleted"
  type        = bool
  default     = false
}
