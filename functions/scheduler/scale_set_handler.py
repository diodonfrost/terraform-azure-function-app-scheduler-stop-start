"""Scale set handler module."""

import logging

from azure.core.exceptions import AzureError
from azure.identity import DefaultAzureCredential
from azure.mgmt.compute import ComputeManagementClient

from .exceptions import azure_exceptions
from .filter_resources_by_tags import FilterByTags


class ScaleSetScheduler:
    """Abstract scale set scheduler in a class."""

    def __init__(self, subscription_id: str) -> None:
        """Initialize Azure client."""
        self.compute_client = ComputeManagementClient(
            credential=DefaultAzureCredential(), subscription_id=subscription_id
        )
        self.tag_filter = FilterByTags(subscription_id)

    def stop(self, azure_tags: dict) -> None:
        """Azure scale set stop function.

        Stop scale sets with defined tags.

        :param str azure_tags:
            The key of the tag that you want to filter by.
            For example: {"key": "value"}
        """
        resource_type = "Microsoft.Compute/virtualMachineScaleSets"
        for scale_set_id in self.tag_filter.get_resources(azure_tags, resource_type):
            scale_set_rg_name = scale_set_id.split("/")[4]
            scale_set_name = scale_set_id.split("/")[-1]
            try:
                self.compute_client.virtual_machine_scale_sets.begin_set_orchestration_service_state(
                    resource_group_name=scale_set_rg_name,
                    vm_scale_set_name=scale_set_name,
                    parameters={"OrchestrationMode": "Suspending"},
                )
            except AzureError as exc:
                if (
                    "Operation 'Suspending' is not allowed on Virtual Machine Scale Set"
                    in str(exc)
                ):
                    logging.info("OrchestrationService AutomaticRepairs is disabled")
                else:
                    logging.error("An error occurred: %s", exc)
            try:
                self.compute_client.virtual_machine_scale_sets.begin_deallocate(
                    resource_group_name=scale_set_rg_name,
                    vm_scale_set_name=scale_set_name,
                    vm_instance_i_ds=None,
                )
                logging.info("Stop scale set: %s", scale_set_id)
            except AzureError as exc:
                azure_exceptions("scale_set", scale_set_id, exc)

    def start(self, azure_tags: dict) -> None:
        """Azure scale set start function.

        Start scale sets with defined tags.

        :param str azure_tags:
            The key of the tag that you want to filter by.
            For example: {"key": "value"}
        """
        resource_type = "Microsoft.Compute/virtualMachineScaleSets"
        for scale_set_id in self.tag_filter.get_resources(azure_tags, resource_type):
            scale_set_rg_name = scale_set_id.split("/")[4]
            scale_set_name = scale_set_id.split("/")[-1]
            try:
                self.compute_client.virtual_machine_scale_sets.begin_set_orchestration_service_state(
                    resource_group_name=scale_set_rg_name,
                    vm_scale_set_name=scale_set_name,
                    parameters={"OrchestrationMode": "Resume"},
                )
            except AzureError as exc:
                if (
                    "Operation 'Resume' is not allowed on Virtual Machine Scale Set"
                    in str(exc)
                ):
                    logging.info("OrchestrationService AutomaticRepairs is disabled")
                else:
                    logging.error("An error occurred: %s", exc)
            try:
                self.compute_client.virtual_machine_scale_sets.begin_start(
                    resource_group_name=scale_set_rg_name,
                    vm_scale_set_name=scale_set_name,
                    vm_instance_i_ds=None,
                )
                logging.info("Start scale set: %s", scale_set_id)
            except AzureError as exc:
                azure_exceptions("scale_set", scale_set_id, exc)
