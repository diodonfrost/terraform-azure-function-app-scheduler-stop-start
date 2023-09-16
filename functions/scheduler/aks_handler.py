"""Aks cluster handler module."""

import logging

from azure.identity import DefaultAzureCredential
from azure.mgmt.containerservice import ContainerServiceClient

from .filter_resources_by_tags import FilterByTags


class AksScheduler:
    """Abstract aks scheduler in a class."""

    def __init__(self, subscription_id: str) -> None:
        """Initialize Azure client."""
        self.aks_client = ContainerServiceClient(
            credential=DefaultAzureCredential(), subscription_id=subscription_id
        )
        self.tag_filter = FilterByTags(subscription_id)

    def stop(self, azure_tags: dict) -> None:
        """Azure aks cluster stop function.

        Stop aks with defined tags.

        :param str azure_tags:
            The key of the tag that you want to filter by.
            For example: {"key": "value"}
        """
        resource_type = "Microsoft.ContainerService/managedClusters"
        for aks_id in self.tag_filter.get_resources(azure_tags, resource_type):
            self.aks_client.managed_clusters.begin_stop(
                resource_group_name=aks_id.split("/")[4],
                resource_name=aks_id.split("/")[-1],
            )
            logging.info("Stop aks cluster: %s", aks_id)

    def start(self, azure_tags: dict) -> None:
        """Azure aks cluster start function.

        Start aks with defined tags.

        :param str azure_tags:
            The key of the tag that you want to filter by.
            For example: {"key": "value"}
        """
        resource_type = "Microsoft.ContainerService/managedClusters"
        for aks_id in self.tag_filter.get_resources(azure_tags, resource_type):
            self.aks_client.managed_clusters.begin_start(
                resource_group_name=aks_id.split("/")[4],
                resource_name=aks_id.split("/")[-1],
            )
            logging.info("Start aks cluster: %s", aks_id)
