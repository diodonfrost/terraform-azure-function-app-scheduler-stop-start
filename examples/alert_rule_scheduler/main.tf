resource "random_pet" "suffix" {}

resource "random_id" "suffix" {
  byte_length = 6
}

resource "azurerm_resource_group" "test" {
  name     = "test-${random_pet.suffix.id}"
  location = "swedencentral"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "test-${random_pet.suffix.id}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "test" {
  name                = "test-${random_pet.suffix.id}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  workspace_id        = azurerm_log_analytics_workspace.test.id
  application_type    = "other"
}

resource "azurerm_monitor_metric_alert" "to_disable" {
  name                = "test-alert-to-disable-${random_pet.suffix.id}"
  resource_group_name = azurerm_resource_group.test.name
  scopes              = [azurerm_application_insights.test.id]
  severity            = 3

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "requests/failed"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = 10
  }

  tags = {
    tostop = "true"
  }
}

resource "azurerm_monitor_metric_alert" "do_not_disable" {
  name                = "test-alert-do-not-disable-${random_pet.suffix.id}"
  resource_group_name = azurerm_resource_group.test.name
  scopes              = [azurerm_application_insights.test.id]
  severity            = 3

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "requests/failed"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = 50
  }

  tags = {
    tostop = "false"
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "to_disable" {
  name                 = "test-sqr-to-disable-${random_pet.suffix.id}"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  scopes               = [azurerm_application_insights.test.id]
  severity             = 3
  evaluation_frequency = "PT5M"
  window_duration      = "PT5M"

  criteria {
    query                   = "requests | where resultCode == '500'"
    time_aggregation_method = "Count"
    operator                = "GreaterThan"
    threshold               = 10

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  tags = {
    tostop = "true"
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "do_not_disable" {
  name                 = "test-sqr-do-not-disable-${random_pet.suffix.id}"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  scopes               = [azurerm_application_insights.test.id]
  severity             = 3
  evaluation_frequency = "PT5M"
  window_duration      = "PT5M"

  criteria {
    query                   = "requests | where resultCode == '500'"
    time_aggregation_method = "Count"
    operator                = "GreaterThan"
    threshold               = 50

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  tags = {
    tostop = "false"
  }
}

resource "azurerm_monitor_activity_log_alert" "to_disable" {
  name                = "test-ala-to-disable-${random_pet.suffix.id}"
  resource_group_name = azurerm_resource_group.test.name
  location            = "global"
  scopes              = ["/subscriptions/${data.azurerm_subscription.current.subscription_id}"]

  criteria {
    category = "ServiceHealth"
  }

  tags = {
    tostop = "true"
  }
}

resource "azurerm_monitor_activity_log_alert" "do_not_disable" {
  name                = "test-ala-do-not-disable-${random_pet.suffix.id}"
  resource_group_name = azurerm_resource_group.test.name
  location            = "global"
  scopes              = ["/subscriptions/${data.azurerm_subscription.current.subscription_id}"]

  criteria {
    category = "ServiceHealth"
  }

  tags = {
    tostop = "false"
  }
}

data "azurerm_subscription" "current" {}


module "disable_alert_rules" {
  source = "../../"

  resource_group_name           = azurerm_resource_group.test.name
  location                      = azurerm_resource_group.test.location
  function_app_name             = "fpn-to-stop-${random_pet.suffix.id}"
  scheduler_action              = "stop"
  scheduler_ncrontab_expression = "0 0 22 * * 1-5"
  alert_rule_schedule           = true
  application_insights = {
    connection_string   = azurerm_application_insights.test.connection_string
    instrumentation_key = azurerm_application_insights.test.instrumentation_key
  }
  scheduler_tag = {
    tostop = "true"
  }
}

module "enable_alert_rules" {
  source = "../../"

  resource_group_name           = azurerm_resource_group.test.name
  location                      = azurerm_resource_group.test.location
  function_app_name             = "fpn-to-start-${random_pet.suffix.id}"
  scheduler_action              = "start"
  scheduler_ncrontab_expression = "0 0 7 * * 1-5"
  alert_rule_schedule           = true
  application_insights = {
    connection_string   = azurerm_application_insights.test.connection_string
    instrumentation_key = azurerm_application_insights.test.instrumentation_key
  }
  scheduler_tag = {
    tostop = "true"
  }
}
