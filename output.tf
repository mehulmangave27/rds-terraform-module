output "db_identifier" {
  value = try(aws_db_instance.db_instance[0].identifier, "")
}
output "db_endpoint" {
  value = try(aws_db_instance.db_instance[0].endpoint, "")
}
output "db_port" {
  value = try(aws_db_instance.db_instance[0].port, "")
}
output "message_for_further_activity" {
  value = try(aws_db_instance.db_instance[0].endpoint, "") != "" ? local.post_provisioning_message : "Database Instance not provisioned"
}
output "error_message" {
  value = local.is_not_oracle ? "" : local.error_message
}