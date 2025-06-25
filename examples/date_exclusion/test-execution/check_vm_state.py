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


def get_vm_state(resource_group_name, vm_name, subscription_id):
    """Get the current state of a virtual machine."""
    try:
        credential = DefaultAzureCredential()
        compute_client = ComputeManagementClient(credential, subscription_id)

        vm_instance = compute_client.virtual_machines.instance_view(
            resource_group_name=resource_group_name, vm_name=vm_name
        )

        for status in vm_instance.statuses:
            if status.code.startswith("PowerState/"):
                return status.code.split("/")[-1]

        return "unknown"
    except ResourceNotFoundError:
        print(f"VM {vm_name} not found in resource group {resource_group_name}")
        return "not_found"
    except Exception as e:
        print(f"Error getting VM state: {str(e)}")
        return "error"


def wait_for_vm_state(
    resource_group_name,
    vm_names,
    desired_state,
    subscription_id,
    max_wait_time=300,
    check_interval=10,
):
    """Wait for VMs to reach the desired state."""
    print(f"Waiting for VMs to reach state: {desired_state}")

    start_time = time.time()

    while time.time() - start_time < max_wait_time:
        all_ready = True

        for vm_name in vm_names:
            current_state = get_vm_state(resource_group_name, vm_name, subscription_id)
            print(f"VM {vm_name} current state: {current_state}")

            if current_state != desired_state:
                all_ready = False
                break

        if all_ready:
            print(f"All VMs are in {desired_state} state")
            return True

        print(f"Waiting {check_interval} seconds before next check...")
        time.sleep(check_interval)

    print(
        f"Timeout: VMs did not reach {desired_state} state within {max_wait_time} seconds"
    )
    return False


def main():
    if len(sys.argv) < 4:
        print(
            "Usage: python check_vm_state.py <desired_status> <resource_group_name> <vm_name1> [vm_name2 ...]"
        )
        print("Example: python check_vm_state.py running my-rg vm1 vm2")
        sys.exit(1)

    desired_state = sys.argv[1]
    resource_group_name = sys.argv[2]
    vm_names = sys.argv[3:]

    # Get subscription ID from az CLI
    subscription_id = get_subscription_id()

    success = wait_for_vm_state(
        resource_group_name=resource_group_name,
        vm_names=vm_names,
        desired_state=desired_state,
        subscription_id=subscription_id,
    )

    if success:
        sys.exit(0)
    else:
        sys.exit(1)


if __name__ == "__main__":
    main()
