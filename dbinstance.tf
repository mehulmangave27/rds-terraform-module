locals {
  final_snapshot_identifier   = var.skip_final_snapshot ? null : "${local.region}d${local.engine_code}${lower(var.application_code)}${local.environment}${var.identifier_count}-${try(random_id.snapshot_identifier[0].hex, "")}-final"
  monitoring_role_arn         = var.create_monitoring_role ? aws_iam_role.enhanced_monitoring[0].arn : var.monitoring_role_arn
  monitoring_role_name        = var.monitoring_role_use_name_prefix ? null : var.monitoring_role_name
  monitoring_role_name_prefix = var.monitoring_role_use_name_prefix ? "${var.monitoring_role_name}-" : null
  region                      = lower(var.region) == "us-east-1" ? "usae" : "deaw"
  engine_code                 = length(var.engine) > 0 ? length(regexall(".*oracle*.", lower(var.engine))) > 0 ? "ora" : length(regexall(".*sqlserver*.", lower(var.engine))) > 0 ? "mss" : length(regexall(".*aurora-mysql*.", lower(var.engine))) > 0 ? "auy" : length(regexall(".*aurora-postgres*.", lower(var.engine))) > 0 ? "aup" : length(regexall(".*mariadb*.", lower(var.engine))) > 0 ? "mar" : length(regexall(".*postgres*.", lower(var.engine))) > 0 ? "pos" : length(regexall(".*mysql*.", lower(var.engine))) > 0 ? "mys" : false : false
  environment                 = lower(var.environment) == "production" ? "p" : (lower(var.environment) == "development" ? "d" : (lower(var.environment) == "stage" ? "s" : "t"))
  is_not_oracle               = length(regexall(".*oracle*.", lower(var.engine))) > 0 ? false : true
  mssql_logs                  = ["agent", "error"]
  mysql_logs                  = ["audit", "error", "general", "slowquery"]
  postgresql_logs             = ["postgresql", "upgrade"]
  instance_identifier         = "${local.region}d${local.engine_code}${lower(var.application_code)}${local.environment}${var.identifier_count}"
  create_parameter_group      = var.create_parameter_group
  create_option_group         = var.create_option_group
  parameter_group_name        = local.create_parameter_group ? aws_db_parameter_group.custom_pg[0].id : var.parameter_group_name
  option_group_name           = local.create_option_group ? aws_db_option_group.custom_og[0].id : var.option_group_name
  post_provisioning_message   = "Hello Team, Requested Database Instance is Provisioned/Terminated. Must not use Master Credential in any application configuration to avoid P1 as it will be rotated. Now contact responsible Database Admin Team with your database list which you want on this database instance with the list of users with required privileges to access the database"
  error_message               = "This module can't be used for oracle provisioning. Oracle Provisioning is highly restricted by the Management. Syngenta highly recommends to migrate your license based platform to open-source"
}



resource "random_id" "snapshot_identifier" {
  count = var.create && !var.skip_final_snapshot && local.is_not_oracle ? 1 : 0

  keepers = {
    id = "${local.region}d${local.engine_code}${lower(var.application_code)}${local.environment}${var.identifier_count}"
  }

  byte_length = 4
}

## Block to get the account ID
data "aws_caller_identity" "account_id" {}

## Code to retrieve master credential from the Secret Manager for the newly requested rds instance
data "aws_secretsmanager_secret" "secret" {
  name = "${data.aws_caller_identity.account_id.account_id}-rds-mastercredentials"
}
data "aws_secretsmanager_secret_version" "creds" {
  # Fill in the name you gave to your secret
  secret_id = data.aws_secretsmanager_secret.secret.id
}


resource "aws_db_instance" "db_instance" {
  count                               = local.is_not_oracle ? 1 : 0
  identifier                          = local.instance_identifier
  engine                              = var.engine
  engine_version                      = var.engine_version
  instance_class                      = var.instance_class
  storage_type                        = var.storage_type
  storage_encrypted                   = var.storage_encrypted
  kms_key_id                          = var.kms_key_id
  allocated_storage                   = var.allocated_storage
  max_allocated_storage               = var.max_allocated_storage
  license_model                       = length(regexall(".*sqlserver*.", lower(var.engine))) > 0 ? "license-included" : (length(regexall(".*postgres*.", lower(var.engine))) > 0) ? "postgresql-license" : "general-public-license"
  db_name                             = var.db_name
  username                            = var.master_username != null ? var.master_username : jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)["username"]
  password                            = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)["password"]
  domain                              = var.domain
  domain_iam_role_name                = var.domain_iam_role_name
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  vpc_security_group_ids              = var.vpc_security_group_ids
  db_subnet_group_name                = var.db_subnet_group_name
  parameter_group_name                = local.parameter_group_name
  option_group_name                   = local.option_group_name
  availability_zone                   = var.availability_zone
  multi_az                            = var.multi_az
  iops                                = var.iops
  publicly_accessible                 = var.publicly_accessible
  ca_cert_identifier                  = var.ca_cert_identifier
  allow_major_version_upgrade         = var.allow_major_version_upgrade
  auto_minor_version_upgrade          = var.auto_minor_version_upgrade
  apply_immediately                   = var.apply_immediately
  maintenance_window                  = var.maintenance_window

  ## provision rds database by using the existing snapshot
  snapshot_identifier       = var.snapshot_identifier
  copy_tags_to_snapshot     = var.copy_tags_to_snapshot # on delete copy all tags to final snapshot
  skip_final_snapshot       = var.skip_final_snapshot   # final snapshot will get created or not before db decommissioned
  final_snapshot_identifier = local.final_snapshot_identifier

  ## Enable Performance Insights for Advanced Database Performance Monitoring feature for 7 days (free tier)
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled == true ? var.performance_insights_retention_period : 0
  performance_insights_kms_key_id       = var.performance_insights_kms_key_id

  replicate_source_db     = var.replicate_source_db
  replica_mode            = var.replica_mode
  backup_retention_period = lower(var.tags["Environment"]) == "production" ? 35 : 14
  backup_window           = var.backup_window

  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_interval > 0 ? local.monitoring_role_arn : null

  character_set_name              = var.character_set_name
  timezone                        = var.timezone
  enabled_cloudwatch_logs_exports = lower(var.engine) == "mysql" ? local.mysql_logs : (lower(var.engine) == "postgres" ? local.postgresql_logs : (length(regexall(".*sqlserver*.", lower(var.engine))) > 0 ? local.mssql_logs : null))

  deletion_protection      = var.deletion_protection
  delete_automated_backups = var.delete_automated_backups
  tags                     = merge({ "IACFramework" = "Terraform" }, var.tags)
  lifecycle {
    create_before_destroy = true
  }
  timeouts {
  create = "2h"
  update = "2h" 
  delete = "2h"
}
}

###############################################################################
## Resource script to create custom parameter group if required
###############################################################################

resource "aws_db_parameter_group" "custom_pg" {
  count = var.create_parameter_group ? 1 : 0

  name        = join("-", [coalesce(var.parameter_group_name, replace(local.instance_identifier, ".", "-")), "custom-tf-pg"])
  description = var.parameter_group_description
  family      = var.parameter_group_family

  dynamic "parameter" {
    for_each = var.parameter_group_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", null)
    }
  }

  tags = merge({ "IACFramework" = "Terraform" }, var.tags)

  lifecycle {
    create_before_destroy = true
  }
}

###############################################################################
## Resource script to create custom option group if required
###############################################################################

resource "aws_db_option_group" "custom_og" {
  count                    = var.create_option_group ? 1 : 0
  name                     = join("-", [coalesce(var.option_group_name, replace(local.instance_identifier, ".", "-")), "custom-tf-og"])
  option_group_description = var.option_group_description
  engine_name              = var.engine
  major_engine_version     = var.major_engine_version

  dynamic "option" {
    for_each = var.options
    content {
      option_name                    = option.value.option_name
      port                           = lookup(option.value, "port", null)
      version                        = lookup(option.value, "version", null)
      db_security_group_memberships  = lookup(option.value, "db_security_group_memberships", null)
      vpc_security_group_memberships = lookup(option.value, "vpc_security_group_memberships", null)

      dynamic "option_settings" {
        for_each = lookup(option.value, "option_settings", [])
        content {
          name  = lookup(option_settings.value, "name", null)
          value = lookup(option_settings.value, "value", null)
        }
      }
    }
  }
  tags = merge({ "IACFramework" = "Terraform" }, var.tags)
  timeouts {
    delete = lookup(var.timeouts, "delete", null)
  }
  lifecycle {
    create_before_destroy = true
  }
}
################################################################################
# Enhanced monitoring
################################################################################
data "aws_iam_policy_document" "enhanced_monitoring" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "enhanced_monitoring" {
  count = var.create_monitoring_role ? 1 : 0

  name               = local.monitoring_role_name
  name_prefix        = local.monitoring_role_name_prefix
  assume_role_policy = data.aws_iam_policy_document.enhanced_monitoring.json
  description        = var.monitoring_role_description

  tags = merge(
    {
      "Name" = format("%s", var.monitoring_role_name), "IACFramework" = "Terraform"
    },
    var.tags,
  )
}

data "aws_partition" "current" {}


resource "aws_iam_role_policy_attachment" "enhanced_monitoring" {
  count = var.create_monitoring_role ? 1 : 0

  role       = aws_iam_role.enhanced_monitoring[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}