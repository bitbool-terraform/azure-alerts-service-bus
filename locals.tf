locals {
  namespace_name = coalesce(var.name, basename(var.service_bus_id))
  
  metric_alerts = {
    server_errors = {
      metric_name = "ServerErrors"
      aggregation = "Total"
      dimension   = null
      config      = var.alerts.server_errors
    }
    throttled_requests = {
      metric_name = "ThrottledRequests"
      aggregation = "Total"
      dimension   = null
      config      = var.alerts.throttled_requests
    }
    deadlettered_messages = {
      metric_name = "DeadletteredMessages"
      aggregation = "Maximum"
      dimension   = "EntityName"
      config      = var.alerts.deadlettered_messages
    }
    active_messages = {
      metric_name = "ActiveMessages"
      aggregation = "Average"
      dimension   = "EntityName"
      config      = var.alerts.active_messages
    }
    user_errors = {
      metric_name = "UserErrors"
      aggregation = "Total"
      dimension   = null
      config      = var.alerts.user_errors
    }
    server_send_latency = {
      metric_name = "ServerSendLatency"
      aggregation = "Average"
      dimension   = "EntityName"
      config      = var.alerts.server_send_latency
    }
    premium_cpu = {
      metric_name = "NamespaceCpuUsage"
      aggregation = "Average"
      dimension   = "Replica"
      config      = var.alerts.premium_cpu
    }
    premium_memory = {
      metric_name = "NamespaceMemoryUsage"
      aggregation = "Average"
      dimension   = "Replica"
      config      = var.alerts.premium_memory
    }
  }

  enabled_alerts = {
    for key, alert in local.metric_alerts : key => alert
    if alert.config.enabled
  }
}