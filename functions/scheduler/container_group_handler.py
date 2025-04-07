"""Container group handler module."""

import logging
from typing import Callable, Tuple

from azure.core.exceptions import AzureError
from azure.identity import DefaultAzureCredential
from azure.mgmt.containerinstance import ContainerInstanceManagementClient

from .exceptions import azure_exceptions
from .filter_resources_by_tags import FilterByTags


class ContainerGroupScheduler:
    """Abstract container group scheduler in a class."""

    RESOURCE_TYPE = "Microsoft.ContainerInstance/containerGroups"

    def __init__(self, subscription_id: str) -> None:
        """Initialize Azure client."""
        self.container_client = ContainerInstanceManagementClient(
            credential=DefaultAzureCredential(), subscription_id=subscription_id
        )
        self.tag_filter = FilterByTags(subscription_id)

    def _parse_resource_id(self, resource_id: str) -> Tuple[str, str]:
        """Extract resource group name and container group name from resource ID.

        :param str resource_id: The Azure resource ID
        :return: Tuple of (resource_group_name, container_group_name)
        """
        parts = resource_id.split("/")
        return parts[4], parts[-1]

    def _perform_action(
        self, azure_tags: dict, action: str, operation: Callable
    ) -> None:
        """Execute an operation on container groups matching the tags.

        :param dict azure_tags: Tags to filter resources by
        :param str action: Action name for logging ("Start" or "Stop")
        :param Callable operation: Function to call on each resource
        """
        for container_id in self.tag_filter.get_resources(
            azure_tags, self.RESOURCE_TYPE
        ):
            try:
                resource_group, container_name = self._parse_resource_id(container_id)
                operation(
                    resource_group_name=resource_group,
                    container_group_name=container_name,
                )
                logging.info("%s Container group: %s", action, container_id)
            except AzureError as exc:
                azure_exceptions("container_group", container_id, exc)

    def stop(self, azure_tags: dict) -> None:
        """Azure Container group stop function.

        Stop container group with the defined tags.

        :param dict azure_tags:
            The key of the tag that you want to filter by.
            For example: {"key": "value"}
        """
        self._perform_action(
            azure_tags, "Stop", self.container_client.container_groups.stop
        )

    def start(self, azure_tags: dict) -> None:
        """Azure Container group start function.

        Start container group with the defined tags.

        :param dict azure_tags:
            The key of the tag that you want to filter by.
            For example: {"key": "value"}
        """
        self._perform_action(
            azure_tags, "Start", self.container_client.container_groups.begin_start
        )
