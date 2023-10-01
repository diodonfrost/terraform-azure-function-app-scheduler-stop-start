"""Container group handler module."""

import logging

from azure.core.exceptions import AzureError
from azure.identity import DefaultAzureCredential
from azure.mgmt.containerinstance import ContainerInstanceManagementClient

from .exceptions import azure_exceptions
from .filter_resources_by_tags import FilterByTags


class ContainerGroupScheduler:
    """Abstract container group scheduler in a class."""

    def __init__(self, subscription_id: str) -> None:
        """Initialize Azure client."""
        self.container_client = ContainerInstanceManagementClient(
            credential=DefaultAzureCredential(), subscription_id=subscription_id
        )
        self.tag_filter = FilterByTags(subscription_id)

    def stop(self, azure_tags: dict) -> None:
        """Azure Container group stop function.

        Stop container group with the defined tags.

        :param str azure_tags:
            The key of the tag that you want to filter by.
            For example: {"key": "value"}
        """
        resource_type = "Microsoft.ContainerInstance/containerGroups"
        for container_id in self.tag_filter.get_resources(azure_tags, resource_type):
            try:
                self.container_client.container_groups.stop(
                    resource_group_name=container_id.split("/")[4],
                    container_group_name=container_id.split("/")[-1],
                )
                logging.info("Stop Container group: %s", container_id)
            except AzureError as exc:
                azure_exceptions("container_group", container_id, exc)

    def start(self, azure_tags: dict) -> None:
        """Azure Container group start function.

        Start container group with the defined tags.

        :param str azure_tags:
            The key of the tag that you want to filter by.
            For example: {"key": "value"}
        """
        resource_type = "Microsoft.ContainerInstance/containerGroups"
        for container_id in self.tag_filter.get_resources(azure_tags, resource_type):
            try:
                self.container_client.container_groups.begin_start(
                    resource_group_name=container_id.split("/")[4],
                    container_group_name=container_id.split("/")[-1],
                )
                logging.info("Start Container group: %s", container_id)
            except AzureError as exc:
                azure_exceptions("container_group", container_id, exc)
