"""Filter azure resouces with tags."""
from typing import Iterator

from azure.identity import DefaultAzureCredential
from azure.mgmt.resource import ResourceManagementClient


class FilterByTags:
    """Abstract Filter azure resources by tags in a class."""

    def __init__(self, subscription_id: str) -> None:
        """Initialize Azure client."""
        self.resource_client = ResourceManagementClient(
            credential=DefaultAzureCredential(), subscription_id=subscription_id
        )

    def get_resources(self, azure_tags: dict, resource_type: str) -> Iterator[str]:
        """Filter azure resources using resource type and defined tags.

        Returns all the tagged defined resources that are located
        in the current subscription.

        :param str azure_tags:
            The key of the tag that you want to filter by.
            For example: {"key": "value"}
        :param str resource_type:
            The type of the resource that you want to filter.
            example: 'Microsoft.Compute/virtualMachines'
        :yield Iterator[dict]:
            The resource group name and the ID of the resource.
        """
        filter_resources = f"resourceType eq '{resource_type}'"
        resources = self.resource_client.resources.list(filter=filter_resources)
        for resource in resources:
            if azure_tags.items() <= resource.tags.items():
                yield resource.id
