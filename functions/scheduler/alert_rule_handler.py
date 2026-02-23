"""Alert rule handler module."""

import logging
from typing import Iterator, Tuple

from azure.core.exceptions import AzureError
from azure.identity import DefaultAzureCredential
from azure.mgmt.monitor import MonitorManagementClient
from azure.mgmt.monitor.models import (
    AlertRulePatchObject,
    MetricAlertResourcePatch,
    ScheduledQueryRuleResourcePatch,
)

from .decorators import skip_on_dry_run
from .exceptions import azure_exceptions
from .filter_resources_by_tags import FilterByTags


class AlertRuleScheduler:
    """Abstract alert rule scheduler in a class."""

    RESOURCE_TYPES = [
        "Microsoft.Insights/metricAlerts",
        "Microsoft.Insights/scheduledQueryRules",
        "Microsoft.Insights/activityLogAlerts",
    ]

    def __init__(self, subscription_id: str) -> None:
        """Initialize Azure client."""
        self.monitor_client = MonitorManagementClient(
            credential=DefaultAzureCredential(), subscription_id=subscription_id
        )
        self.tag_filter = FilterByTags(subscription_id)

    def _parse_resource_id(self, resource_id: str) -> Tuple[str, str]:
        """Extract resource group name and alert rule name from resource ID.

        :param str resource_id: The Azure resource ID
        :return: Tuple of (resource_group_name, rule_name)
        """
        parts = resource_id.split("/")
        return parts[4], parts[-1]

    def _get_resource_type(self, resource_id: str) -> str:
        """Extract the resource type from a resource ID.

        :param str resource_id: The Azure resource ID
        :return: The resource type string
        """
        parts = resource_id.split("/")
        return f"{parts[6]}/{parts[7]}"

    def list_resources(self, azure_tags: dict) -> Iterator[str]:
        """List alert rules matching the given tags across all alert types.

        :param dict azure_tags: Tags to filter resources by
        :return: Iterator of resource IDs
        """
        for resource_type in self.RESOURCE_TYPES:
            yield from self.tag_filter.get_resources(azure_tags, resource_type)

    @skip_on_dry_run
    def _perform_action(self, resource_id: str, action: str) -> None:
        """Disable or enable a single alert rule.

        :param str resource_id: The Azure resource ID
        :param str action: "Disable" or "Enable"
        """
        try:
            resource_group, rule_name = self._parse_resource_id(resource_id)
            resource_type = self._get_resource_type(resource_id).lower()
            enabled = action == "Enable"

            if resource_type == "microsoft.insights/metricalerts":
                self.monitor_client.metric_alerts.update(
                    resource_group_name=resource_group,
                    rule_name=rule_name,
                    parameters=MetricAlertResourcePatch(enabled=enabled),
                )
            elif resource_type == "microsoft.insights/scheduledqueryrules":
                self.monitor_client.scheduled_query_rules.update(
                    resource_group_name=resource_group,
                    rule_name=rule_name,
                    parameters=ScheduledQueryRuleResourcePatch(enabled=enabled),
                )
            elif resource_type == "microsoft.insights/activitylogalerts":
                self.monitor_client.activity_log_alerts.update(
                    resource_group_name=resource_group,
                    activity_log_alert_name=rule_name,
                    activity_log_alert_rule_patch=AlertRulePatchObject(enabled=enabled),
                )

            logging.info("%s alert rule: %s", action, resource_id)
        except AzureError as exc:
            azure_exceptions("alert_rule", resource_id, exc)

    def stop(self, azure_tags: dict) -> None:
        """Disable alert rules with defined tags.

        :param dict azure_tags:
            The key of the tag that you want to filter by.
            For example: {"key": "value"}
        """
        for resource_id in self.list_resources(azure_tags):
            self._perform_action(resource_id, "Disable")

    def start(self, azure_tags: dict) -> None:
        """Enable alert rules with defined tags.

        :param dict azure_tags:
            The key of the tag that you want to filter by.
            For example: {"key": "value"}
        """
        for resource_id in self.list_resources(azure_tags):
            self._perform_action(resource_id, "Enable")
