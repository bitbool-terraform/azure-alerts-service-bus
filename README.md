# azure-alerts-servicebus
## Usage

```hcl
module "azure-alerts-servicebus" {
  source = "../../bitbool-terraform/azure-alerts-service-bus"

  name             = module.azure-servicebus.name
  resource_group   = var.resource_group
  location         = var.location
  service_bus_id   = module.azure-servicebus.id
  action_group_ids = var.alerts_action_group_ids

  alerts = {
    # Optional namespace-wide changes
    user_errors = { enabled = false, threshold = 300 }
  }

  # Optional: queue-specific configurations, no rules created by default.

  entity_alerts = {
    notification_backlog_warning = {
      entity_name = "notification_event_queue"
      metric      = "ActiveMessages" # default
      threshold   = 750000
      severity    = 2
    }
    notification_backlog_critical = {
      entity_name = "notification_event_queue"
      threshold   = 900000
      severity    = 1
    }
    notification_storage_80pct = {
      entity_name = "notification_event_queue"
      metric      = "Size"
      # 80% of 1 GiB = 858,993,459.2 bytes; integer ceiling rounded down.
      threshold   = 858993459
      severity    = 1
      frequency   = "PT1M"
      window_size = "PT5M"
    }
    audit_backlog = {
      entity_name = "audit_queue"
      threshold   = 3000
      severity    = 2
    }
  }
}
```