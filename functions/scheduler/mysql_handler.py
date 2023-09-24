"""mysql handler module."""

import logging

from azure.core.exceptions import AzureError
from azure.identity import DefaultAzureCredential
from azure.mgmt.rdbms.mysql_flexibleservers import MySQLManagementClient

from .exceptions import azure_exceptions
from .filter_resources_by_tags import FilterByTags


class MySqlScheduler:
    """Abstract mysql scheduler in a class."""

    def __init__(self, subscription_id: str) -> None:
        """Initialize Azure client."""
        self.mysql_client = MySQLManagementClient(
            credential=DefaultAzureCredential(), subscription_id=subscription_id
        )
        self.tag_filter = FilterByTags(subscription_id)

    def stop(self, azure_tags: dict) -> None:
        """Azure mysql stop function.

        Stop mysql with defined tags.

        :param str azure_tags:
            The key of the tag that you want to filter by.
            For example: {"key": "value"}
        """
        resource_type = "Microsoft.DBforMySQL/flexibleServers"
        for mysql_id in self.tag_filter.get_resources(azure_tags, resource_type):
            try:
                self.mysql_client.servers.begin_stop(
                    resource_group_name=mysql_id.split("/")[4],
                    server_name=mysql_id.split("/")[-1],
                )
                logging.info("Stop mysql: %s", mysql_id)
            except AzureError as exc:
                azure_exceptions("mysql", mysql_id, exc)

    def start(self, azure_tags: dict) -> None:
        """Azure mysql start function.

        Start mysql with defined tags.

        :param str azure_tags:
            The key of the tag that you want to filter by.
            For example: {"key": "value"}
        """
        resource_type = "Microsoft.DBforMySQL/flexibleServers"
        for mysql_id in self.tag_filter.get_resources(azure_tags, resource_type):
            try:
                self.mysql_client.servers.begin_start(
                    resource_group_name=mysql_id.split("/")[4],
                    server_name=mysql_id.split("/")[-1],
                )
                logging.info("Start mysql: %s", mysql_id)
            except AzureError as exc:
                azure_exceptions("mysql", mysql_id, exc)
