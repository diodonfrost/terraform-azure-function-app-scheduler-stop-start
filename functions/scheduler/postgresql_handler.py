"""postgresql handler module."""

import logging
from typing import Callable, Tuple

from azure.core.exceptions import AzureError
from azure.identity import DefaultAzureCredential
from azure.mgmt.rdbms.postgresql_flexibleservers import PostgreSQLManagementClient

from .exceptions import azure_exceptions
from .filter_resources_by_tags import FilterByTags


class PostgresSqlScheduler:
    """Abstract postgresql scheduler in a class."""

    RESOURCE_TYPE = "Microsoft.DBforPostgreSQL/flexibleServers"

    def __init__(self, subscription_id: str) -> None:
        """Initialize Azure client."""
        self.postgres_client = PostgreSQLManagementClient(
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
        """Execute an operation on PostgreSQL servers matching the tags.

        :param dict azure_tags: Tags to filter resources by
        :param str action: Action name for logging ("Start" or "Stop")
        :param Callable operation: Function to call on each resource
        """
        for pg_id in self.tag_filter.get_resources(azure_tags, self.RESOURCE_TYPE):
            try:
                resource_group, server_name = self._parse_resource_id(pg_id)
                operation(resource_group_name=resource_group, server_name=server_name)
                logging.info("%s postgresql: %s", action, pg_id)
            except AzureError as exc:
                azure_exceptions("postgresql", pg_id, exc)

    def stop(self, azure_tags: dict) -> None:
        """Azure postgresql stop function.

        Stop postgresql with defined tags.

        :param dict azure_tags:
            The key of the tag that you want to filter by.
            For example: {"key": "value"}
        """
        self._perform_action(
            azure_tags, "Stop", self.postgres_client.servers.begin_stop
        )

    def start(self, azure_tags: dict) -> None:
        """Azure postgresql start function.

        Start postgresql with defined tags.

        :param dict azure_tags:
            The key of the tag that you want to filter by.
            For example: {"key": "value"}
        """
        self._perform_action(
            azure_tags, "Start", self.postgres_client.servers.begin_start
        )
