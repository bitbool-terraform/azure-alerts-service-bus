resource "azurerm_monitor_metric_alert" "this" {
  for_each = local.enabled_alerts

  name                     = "${local.namespace_name}-sb-${replace(each.key, "_", "-")}"
  resource_group_name      = var.resource_group
  scopes                   = [var.service_bus_id]
  target_resource_type     = "Microsoft.ServiceBus/namespaces"
  target_resource_location = var.location

  description   = "Service Bus ${each.value.metric_name} ${each.value.aggregation} > ${each.value.config.threshold} over ${each.value.config.window_size}."
  severity      = each.value.config.severity
  enabled       = true
  auto_mitigate = true
  frequency     = each.value.config.frequency
  window_size   = each.value.config.window_size

  criteria {
    metric_namespace = "Microsoft.ServiceBus/namespaces"
    metric_name      = each.value.metric_name
    aggregation      = each.value.aggregation
    operator         = "GreaterThan"
    threshold        = each.value.config.threshold

    # '*' selects current and future queues/topics (or Premium replicas).
    dynamic "dimension" {
      for_each = each.value.dimension == null ? [] : [each.value.dimension]
      content {
        name     = dimension.value
        operator = "Include"
        values   = ["*"]
      }
    }
  }

  dynamic "action" {
    for_each = toset(var.action_group_ids)
    content {
      action_group_id = action.value
    }
  }
}

# Individual queue/topic alert rules.
resource "azurerm_monitor_metric_alert" "entity" {
  for_each = {
    for key, rule in var.entity_alerts : key => rule
    if rule.enabled
  }

  name                     = "${local.namespace_name}-sb-${replace(each.key, "_", "-")}"
  resource_group_name      = var.resource_group
  scopes                   = [var.service_bus_id]
  target_resource_type     = "Microsoft.ServiceBus/namespaces"
  target_resource_location = var.location

  description   = "Service Bus ${each.value.entity_name}: ${each.value.metric} > ${each.value.threshold} over ${each.value.window_size}."
  severity      = each.value.severity
  enabled       = true
  auto_mitigate = true
  frequency     = each.value.frequency
  window_size   = each.value.window_size

  criteria {
    metric_namespace = "Microsoft.ServiceBus/namespaces"
    metric_name      = each.value.metric
    aggregation      = each.value.metric == "Size" ? "Maximum" : "Average"
    operator         = "GreaterThan"
    threshold        = each.value.threshold

    dimension {
      name     = "EntityName"
      operator = "Include"
      values   = [each.value.entity_name]
    }
  }

  dynamic "action" {
    for_each = toset(var.action_group_ids)
    content {
      action_group_id = action.value
    }
  }
}
