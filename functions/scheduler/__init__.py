"""Main function entrypoint for Azure Function App."""

import json
import logging
import os
from datetime import datetime

import azure.functions as func

from .aks_handler import AksScheduler
from .container_group_handler import ContainerGroupScheduler
from .mysql_handler import MySqlScheduler
from .postgresql_handler import PostgresSqlScheduler
from .scale_set_handler import ScaleSetScheduler
from .virtual_machine_handler import VirtualMachineScheduler


def main(scheduler: func.TimerRequest) -> None:
    """Main function entrypoint for Azure Function App."""
    excluded_dates = json.loads(os.environ.get("SCHEDULER_EXCLUDED_DATES", "[]"))

    if is_date_excluded(excluded_dates):
        return

    scheduler_action = os.environ["SCHEDULER_ACTION"]
    azure_tags = json.loads(os.environ["SCHEDULER_TAG"])
    current_subscription_id = os.environ["CURRENT_SUBSCRIPTION_ID"]

    azure_services = {
        VirtualMachineScheduler: os.environ["VIRTUAL_MACHINE_SCHEDULE"],
        ScaleSetScheduler: os.environ["SCALE_SET_SCHEDULE"],
        PostgresSqlScheduler: os.environ["POSTGRESQL_SCHEDULE"],
        MySqlScheduler: os.environ["MYSQL_SCHEDULE"],
        AksScheduler: os.environ["AKS_SCHEDULE"],
        ContainerGroupScheduler: os.environ["CONTAINER_GROUP_SCHEDULE"],
    }

    for service, to_schedule in azure_services.items():
        if strtobool(to_schedule):
            _azure_services = service(current_subscription_id)
            getattr(_azure_services, scheduler_action)(azure_tags=azure_tags)


def strtobool(value: str) -> bool:
    """Convert string to boolean."""
    return value.lower() in ("yes", "true", "t", "1")


def is_date_excluded(excluded_dates: list[str]) -> bool:
    """Check if the current date should be excluded from scheduling.

    Args:
        excluded_dates: List of dates in MM-DD format to exclude

    Returns:
        True if current date should be excluded, False otherwise
    """
    if not excluded_dates:
        return False

    current_date = datetime.now()
    current_date_str = current_date.strftime("%m-%d")

    if current_date_str in excluded_dates:
        logging.info(
            "Skipping execution - current date (%s) is in excluded dates: %s",
            current_date_str,
            excluded_dates,
        )
        return True

    return False
