output "alert_ids" {
  description = "Map of created alert keys to Azure Monitor metric alert IDs."
  value       = { for key, alert in azurerm_monitor_metric_alert.this : key => alert.id }
}

output "entity_alert_ids" {
  description = "Map of custom per-entity alert keys to Azure Monitor metric alert IDs."
  value       = { for key, alert in azurerm_monitor_metric_alert.entity : key => alert.id }
}
