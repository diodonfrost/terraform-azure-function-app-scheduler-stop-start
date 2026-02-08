"""Aks cluster handler module."""

import logging
from typing import Callable, Iterator, Tuple

from azure.core.exceptions import AzureError
from azure.identity import DefaultAzureCredential
from azure.mgmt.containerservice import ContainerServiceClient

from .decorators import skip_on_dry_run
from .exceptions import azure_exceptions
from .filter_resources_by_tags import FilterByTags


class AksScheduler:
    """Abstract aks scheduler in a class."""

    RESOURCE_TYPE = "Microsoft.ContainerService/managedClusters"

    def __init__(self, subscription_id: str) -> None:
        """Initialize Azure client."""
        self.aks_client = ContainerServiceClient(
            credential=DefaultAzureCredential(), subscription_id=subscription_id
        )
        self.tag_filter = FilterByTags(subscription_id)

    def _parse_resource_id(self, resource_id: str) -> Tuple[str, str]:
        """Extract resource group name and AKS cluster name from resource ID.

        :param str resource_id: The Azure resource ID
        :return: Tuple of (resource_group_name, resource_name)
        """
        parts = resource_id.split("/")
        return parts[4], parts[-1]

    def list_resources(self, azure_tags: dict) -> Iterator[str]:
        """List AKS clusters matching the given tags.

        :param dict azure_tags: Tags to filter resources by
        :return: Iterator of resource IDs
        """
        return self.tag_filter.get_resources(azure_tags, self.RESOURCE_TYPE)

    @skip_on_dry_run
    def _perform_action(
        self, resource_id: str, action: str, operation: Callable
    ) -> None:
        """Execute an operation on a single AKS cluster.

        :param str resource_id: The Azure resource ID
        :param str action: Action name for logging ("Start" or "Stop")
        :param Callable operation: Function to call on the resource
        """
        try:
            resource_group, resource_name = self._parse_resource_id(resource_id)
            operation(resource_group_name=resource_group, resource_name=resource_name)
            logging.info("%s aks cluster: %s", action, resource_id)
        except AzureError as exc:
            azure_exceptions("aks", resource_id, exc)

    def stop(self, azure_tags: dict) -> None:
        """Azure aks cluster stop function.

        Stop aks with defined tags.

        :param dict azure_tags:
            The key of the tag that you want to filter by.
            For example: {"key": "value"}
        """
        for resource_id in self.list_resources(azure_tags):
            self._perform_action(
                resource_id, "Stop", self.aks_client.managed_clusters.begin_stop
            )

    def start(self, azure_tags: dict) -> None:
        """Azure aks cluster start function.

        Start aks with defined tags.

        :param dict azure_tags:
            The key of the tag that you want to filter by.
            For example: {"key": "value"}
        """
        for resource_id in self.list_resources(azure_tags):
            self._perform_action(
                resource_id, "Start", self.aks_client.managed_clusters.begin_start
            )
