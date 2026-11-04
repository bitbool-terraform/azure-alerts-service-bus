variable "resource_group" {
  type        = string
}

variable "location" {
  type        = string
}

variable "service_bus_id" {
  type        = string
}

variable "name" {
  type        = string
  default     = null
}

variable "action_group_ids" {
  type        = list(string)

  validation {
    condition     = length(var.action_group_ids) > 0
    error_message = "Provide at least one action group ID."
  }
}

variable "alerts" {
  type = object({

    # Service-side request failures (total in 5 minutes).
    server_errors = optional(object({
      enabled     = optional(bool, true)
      threshold   = optional(number, 2)
      severity    = optional(number, 1)
      frequency   = optional(string, "PT1M")
      window_size = optional(string, "PT5M")
    }), {})

    # Service throttling (total in 5 minutes).
    throttled_requests = optional(object({
      enabled     = optional(bool, true)
      threshold   = optional(number, 0)
      severity    = optional(number, 2)
      frequency   = optional(string, "PT1M")
      window_size = optional(string, "PT5M")
    }), {})

    # Any DLQ backlog for an individual entity; point-in-time count.
    deadlettered_messages = optional(object({
      enabled     = optional(bool, true)
      threshold   = optional(number, 0)
      severity    = optional(number, 2)
      frequency   = optional(string, "PT1M")
      window_size = optional(string, "PT5M")
    }), {})

    # Sustained queue/topic backlog
    active_messages = optional(object({
      enabled     = optional(bool, false)
      threshold   = optional(number, 1000)
      severity    = optional(number, 2)
      frequency   = optional(string, "PT5M")
      window_size = optional(string, "PT15M")
    }), {})

    # Client/application errors; often noisy.
    user_errors = optional(object({
      enabled     = optional(bool, false)
      threshold   = optional(number, 300)
      severity    = optional(number, 3)
      frequency   = optional(string, "PT1M")
      window_size = optional(string, "PT5M")
    }), {})

    # Average server-side send latency in milliseconds.
    server_send_latency = optional(object({
      enabled     = optional(bool, false)
      threshold   = optional(number, 500)
      severity    = optional(number, 2)
      frequency   = optional(string, "PT5M")
      window_size = optional(string, "PT15M")
    }), {})

    # Premium only; Microsoft scaling guidance is 75% sustained CPU.
    premium_cpu = optional(object({
      enabled     = optional(bool, false)
      threshold   = optional(number, 75)
      severity    = optional(number, 2)
      frequency   = optional(string, "PT5M")
      window_size = optional(string, "PT15M")
    }), {})

    # Premium only; Microsoft scaling guidance is 60% sustained memory.
    premium_memory = optional(object({
      enabled     = optional(bool, false)
      threshold   = optional(number, 60)
      severity    = optional(number, 2)
      frequency   = optional(string, "PT5M")
      window_size = optional(string, "PT15M")
    }), {})
  })
  default = {}

  validation {
    condition = alltrue([
      var.alerts.server_errors.threshold >= 0 && var.alerts.server_errors.severity >= 0 && var.alerts.server_errors.severity <= 4,
      var.alerts.throttled_requests.threshold >= 0 && var.alerts.throttled_requests.severity >= 0 && var.alerts.throttled_requests.severity <= 4,
      var.alerts.deadlettered_messages.threshold >= 0 && var.alerts.deadlettered_messages.severity >= 0 && var.alerts.deadlettered_messages.severity <= 4,
      var.alerts.active_messages.threshold >= 0 && var.alerts.active_messages.severity >= 0 && var.alerts.active_messages.severity <= 4,
      var.alerts.user_errors.threshold >= 0 && var.alerts.user_errors.severity >= 0 && var.alerts.user_errors.severity <= 4,
      var.alerts.server_send_latency.threshold >= 0 && var.alerts.server_send_latency.severity >= 0 && var.alerts.server_send_latency.severity <= 4,
      var.alerts.premium_cpu.threshold >= 0 && var.alerts.premium_cpu.severity >= 0 && var.alerts.premium_cpu.severity <= 4,
      var.alerts.premium_memory.threshold >= 0 && var.alerts.premium_memory.severity >= 0 && var.alerts.premium_memory.severity <= 4,
    ])
    error_message = "Every alert threshold must be >= 0 and severity must be 0..4."
  }
}

variable "entity_alerts" {
  description = "Optional custom backlog or storage alerts for individual queues/topics. Map keys must be unique alert-name suffixes."
  type = map(object({
    enabled     = optional(bool, true)
    entity_name = string
    metric      = optional(string, "ActiveMessages") # ActiveMessages or Size
    threshold   = number
    severity    = optional(number, 2)
    frequency   = optional(string, "PT5M")
    window_size = optional(string, "PT15M")
  }))
  default = {}

  validation {
    condition = alltrue([
      for key, rule in var.entity_alerts :
      can(regex("^[a-z0-9][a-z0-9_-]*$", key)) &&
      length(trimspace(rule.entity_name)) > 0 &&
      contains(["ActiveMessages", "Size"], rule.metric) &&
      rule.threshold >= 0 &&
      rule.severity >= 0 && rule.severity <= 4
    ])
    error_message = "Each entity alert needs a valid key, entity_name, ActiveMessages or Size metric, threshold >= 0, and severity 0..4."
  }
}
