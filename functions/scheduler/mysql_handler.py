"""mysql handler module."""

import logging
from typing import Callable, Tuple

from azure.core.exceptions import AzureError
from azure.identity import DefaultAzureCredential
from azure.mgmt.rdbms.mysql_flexibleservers import MySQLManagementClient

from .exceptions import azure_exceptions
from .filter_resources_by_tags import FilterByTags


class MySqlScheduler:
    """Abstract mysql scheduler in a class."""

    RESOURCE_TYPE = "Microsoft.DBforMySQL/flexibleServers"

    def __init__(self, subscription_id: str) -> None:
        """Initialize Azure client."""
        self.mysql_client = MySQLManagementClient(
            credential=DefaultAzureCredential(), subscription_id=subscription_id
        )
        self.tag_filter = FilterByTags(subscription_id)

    def _parse_resource_id(self, resource_id: str) -> Tuple[str, str]:
        """Extract resource group name and server name from resource ID.

        :param str resource_id: The Azure resource ID
        :return: Tuple of (resource_group_name, server_name)
        """
        parts = resource_id.split("/")
        return parts[4], parts[-1]

    def _perform_action(
        self, azure_tags: dict, action: str, operation: Callable
    ) -> None:
        """Execute an operation on MySQL servers matching the tags.

        :param dict azure_tags: Tags to filter resources by
        :param str action: Action name for logging ("Start" or "Stop")
        :param Callable operation: Function to call on each resource
        """
        for mysql_id in self.tag_filter.get_resources(azure_tags, self.RESOURCE_TYPE):
            try:
                resource_group, server_name = self._parse_resource_id(mysql_id)
                operation(resource_group_name=resource_group, server_name=server_name)
                logging.info("%s mysql: %s", action, mysql_id)
            except AzureError as exc:
                azure_exceptions("mysql", mysql_id, exc)

    def stop(self, azure_tags: dict) -> None:
        """Azure mysql stop function.

        Stop mysql with defined tags.

        :param dict azure_tags:
            The key of the tag that you want to filter by.
            For example: {"key": "value"}
        """
        self._perform_action(azure_tags, "Stop", self.mysql_client.servers.begin_stop)

    def start(self, azure_tags: dict) -> None:
        """Azure mysql start function.

        Start mysql with defined tags.

        :param dict azure_tags:
            The key of the tag that you want to filter by.
            For example: {"key": "value"}
        """
        self._perform_action(azure_tags, "Start", self.mysql_client.servers.begin_start)
