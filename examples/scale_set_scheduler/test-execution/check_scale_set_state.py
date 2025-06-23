#!/usr/bin/env python3

import json
import subprocess
import sys
import time

from azure.core.exceptions import ResourceNotFoundError
from azure.identity import DefaultAzureCredential
from azure.mgmt.compute import ComputeManagementClient


def get_subscription_id():
    """Get the current subscription ID from az CLI."""
    try:
        result = subprocess.run(
            ["az", "account", "show"], capture_output=True, text=True, check=True
        )
        account_info = json.loads(result.stdout)
        return account_info["id"]
    except (subprocess.CalledProcessError, json.JSONDecodeError, KeyError) as e:
        print(f"Error getting subscription ID: {e}")
        print("Make sure you are logged in with 'az login'")
        sys.exit(1)


def get_scale_set_state(resource_group_name, scale_set_name, subscription_id):
    """Get the current state of a Virtual Machine Scale Set."""
    try:
        credential = DefaultAzureCredential()
        compute_client = ComputeManagementClient(credential, subscription_id)

        compute_client.virtual_machine_scale_sets.get(
            resource_group_name=resource_group_name, vm_scale_set_name=scale_set_name
        )

        # Get instances to determine state
        instances = compute_client.virtual_machine_scale_set_vms.list(
            resource_group_name=resource_group_name,
            virtual_machine_scale_set_name=scale_set_name,
        )

        instance_count = 0
        running_count = 0

        for instance in instances:
            instance_count += 1
            instance_view = (
                compute_client.virtual_machine_scale_set_vms.get_instance_view(
                    resource_group_name=resource_group_name,
                    vm_scale_set_name=scale_set_name,
                    instance_id=instance.instance_id,
                )
            )

            for status in instance_view.statuses:
                if status.code.startswith("PowerState/"):
                    if status.code.split("/")[-1] == "running":
                        running_count += 1
                    break

        if instance_count == 0:
            return "deallocated"
        elif running_count == instance_count:
            return "running"
        elif running_count == 0:
            return "deallocated"
        else:
            return "partially_running"

    except ResourceNotFoundError:
        print(
            f"Scale Set {scale_set_name} not found in resource group {resource_group_name}"
        )
        return "not_found"
    except Exception as e:
        print(f"Error getting Scale Set state: {str(e)}")
        return "error"


def wait_for_scale_set_state(
    resource_group_name,
    scale_set_names,
    desired_state,
    subscription_id,
    max_wait_time=600,
    check_interval=30,
):
    """Wait for Scale Sets to reach the desired state."""
    print(f"Waiting for Scale Sets to reach state: {desired_state}")

    start_time = time.time()

    while time.time() - start_time < max_wait_time:
        all_ready = True

        for scale_set_name in scale_set_names:
            current_state = get_scale_set_state(
                resource_group_name, scale_set_name, subscription_id
            )
            print(f"Scale Set {scale_set_name} current state: {current_state}")

            if current_state != desired_state:
                all_ready = False
                break

        if all_ready:
            print(f"All Scale Sets are in {desired_state} state")
            return True

        print(f"Waiting {check_interval} seconds before next check...")
        time.sleep(check_interval)

    print(
        f"Timeout: Scale Sets did not reach {desired_state} state within {max_wait_time} seconds"
    )
    return False


def main():
    if len(sys.argv) < 4:
        print(
            "Usage: python check_scale_set_state.py <desired_status> <resource_group_name> <scale_set_name1> [scale_set_name2 ...]"
        )
        print("Example: python check_scale_set_state.py running my-rg vmss1 vmss2")
        sys.exit(1)

    desired_state = sys.argv[1]
    resource_group_name = sys.argv[2]
    scale_set_names = sys.argv[3:]

    # Get subscription ID from az CLI
    subscription_id = get_subscription_id()

    success = wait_for_scale_set_state(
        resource_group_name=resource_group_name,
        scale_set_names=scale_set_names,
        desired_state=desired_state,
        subscription_id=subscription_id,
    )

    if success:
        sys.exit(0)
    else:
        sys.exit(1)


if __name__ == "__main__":
    main()
