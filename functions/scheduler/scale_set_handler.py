"""Scale set handler module."""

import logging
from typing import Callable, Iterator, Tuple

from azure.core.exceptions import AzureError
from azure.identity import DefaultAzureCredential
from azure.mgmt.compute import ComputeManagementClient

from .exceptions import azure_exceptions
from .filter_resources_by_tags import FilterByTags


class ScaleSetScheduler:
    """Abstract scale set scheduler in a class."""

    RESOURCE_TYPE = "Microsoft.Compute/virtualMachineScaleSets"

    def __init__(self, subscription_id: str) -> None:
        """Initialize Azure client."""
        self.compute_client = ComputeManagementClient(
            credential=DefaultAzureCredential(), subscription_id=subscription_id
        )
        self.tag_filter = FilterByTags(subscription_id)

    def _parse_resource_id(self, resource_id: str) -> Tuple[str, str]:
        """Extract resource group name and scale set name from resource ID.

        :param str resource_id: The Azure resource ID
        :return: Tuple of (resource_group_name, scale_set_name)
        """
        parts = resource_id.split("/")
        return parts[4], parts[-1]

    def list_resources(self, azure_tags: dict) -> Iterator[str]:
        """List scale sets matching the given tags.

        :param dict azure_tags: Tags to filter resources by
        :return: Iterator of resource IDs
        """
        return self.tag_filter.get_resources(azure_tags, self.RESOURCE_TYPE)

    def _set_orchestration_state(
        self, resource_group: str, scale_set_name: str, mode: str
    ) -> None:
        """Set the orchestration service state for a scale set.

        :param str resource_group: The resource group name
        :param str scale_set_name: The scale set name
        :param str mode: The orchestration mode ("Suspending" or "Resume")
        """
        try:
            self.compute_client.virtual_machine_scale_sets.begin_set_orchestration_service_state(
                resource_group_name=resource_group,
                vm_scale_set_name=scale_set_name,
                parameters={"OrchestrationMode": mode},
            )
        except AzureError as exc:
            operation_not_allowed = (
                f"Operation '{mode}' is not allowed on Virtual Machine Scale Set"
            )
            if operation_not_allowed in str(exc):
                logging.info("OrchestrationService AutomaticRepairs is disabled")
            else:
                logging.error("An error occurred: %s", exc)

    def _perform_action(
        self, resource_id: str, action: str, operation: Callable
    ) -> None:
        """Execute an operation on a single scale set.

        :param str resource_id: The Azure resource ID
        :param str action: Action name for logging ("Start" or "Stop")
        :param Callable operation: Function to call on the resource
        """
        resource_group, scale_set_name = self._parse_resource_id(resource_id)

        orchestration_mode = "Suspending" if action == "Stop" else "Resume"
        self._set_orchestration_state(
            resource_group, scale_set_name, orchestration_mode
        )

        try:
            operation(
                resource_group_name=resource_group,
                vm_scale_set_name=scale_set_name,
                vm_instance_i_ds=None,
            )
            logging.info("%s scale set: %s", action, resource_id)
        except AzureError as exc:
            azure_exceptions("scale_set", resource_id, exc)

    def stop(self, azure_tags: dict) -> None:
        """Azure scale set stop function.

        Stop scale sets with defined tags.

        :param dict azure_tags:
            The key of the tag that you want to filter by.
            For example: {"key": "value"}
        """
        for scale_set_id in self.list_resources(azure_tags):
            self._perform_action(
                scale_set_id,
                "Stop",
                self.compute_client.virtual_machine_scale_sets.begin_deallocate,
            )

    def start(self, azure_tags: dict) -> None:
        """Azure scale set start function.

        Start scale sets with defined tags.

        :param dict azure_tags:
            The key of the tag that you want to filter by.
            For example: {"key": "value"}
        """
        for scale_set_id in self.list_resources(azure_tags):
            self._perform_action(
                scale_set_id,
                "Start",
                self.compute_client.virtual_machine_scale_sets.begin_start,
            )
