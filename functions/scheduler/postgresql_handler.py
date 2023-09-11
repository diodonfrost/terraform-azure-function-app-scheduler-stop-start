"""postgresql handler module."""

import logging

from azure.identity import DefaultAzureCredential
from azure.mgmt.rdbms.postgresql_flexibleservers import PostgreSQLManagementClient

from .filter_resources_by_tags import FilterByTags


class PostgresSqlScheduler:
    """Abstract postgresql scheduler in a class."""

    def __init__(self, subscription_id: str) -> None:
        """Initialize Azure client."""
        self.postgres_client = PostgreSQLManagementClient(
            credential=DefaultAzureCredential(), subscription_id=subscription_id
        )
        self.tag_filter = FilterByTags(subscription_id)

    def stop(self, azure_tags: dict) -> None:
        """Azure postgresql stop function.

        Stop postgresql with defined tags.

        :param str azure_tags:
            The key of the tag that you want to filter by.
            For example: {"key": "value"}
        """
        resource_type = "Microsoft.DBforPostgreSQL/flexibleServers"
        for pg_id in self.tag_filter.get_resources(azure_tags, resource_type):
            self.postgres_client.servers.begin_stop(
                resource_group_name=pg_id.split("/")[4],
                server_name=pg_id.split("/")[-1],
            )
            logging.info("Stop postgresql: %s", pg_id)

    def start(self, azure_tags: dict) -> None:
        """Azure postgresql start function.

        Start postgresql with defined tags.

        :param str azure_tags:
            The key of the tag that you want to filter by.
            For example: {"key": "value"}
        """
        resource_type = "Microsoft.DBforPostgreSQL/flexibleServers"
        for pg_id in self.tag_filter.get_resources(azure_tags, resource_type):
            self.postgres_client.servers.begin_start(
                resource_group_name=pg_id.split("/")[4],
                server_name=pg_id.split("/")[-1],
            )
            logging.info("Start postgresql: %s", pg_id)
