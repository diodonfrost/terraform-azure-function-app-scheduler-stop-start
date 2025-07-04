"""Main function entrypoint for Azure Function App."""

import json
import os

import azure.functions as func

from .aks_handler import AksScheduler
from .container_group_handler import ContainerGroupScheduler
from .mysql_handler import MySqlScheduler
from .postgresql_handler import PostgresSqlScheduler
from .scale_set_handler import ScaleSetScheduler
from .utils import is_date_excluded, strtobool
from .virtual_machine_handler import VirtualMachineScheduler


def main(scheduler: func.TimerRequest) -> None:
    """Main function entrypoint for Azure Function App."""
    excluded_dates = json.loads(os.environ.get("SCHEDULER_EXCLUDED_DATES", "[]"))

    if is_date_excluded(excluded_dates):
        return

    scheduler_action = os.environ["SCHEDULER_ACTION"]
    azure_tags = json.loads(os.environ["SCHEDULER_TAG"])
    subscription_ids = json.loads(
        os.environ.get(
            "SUBSCRIPTION_IDS", f'["{os.environ["CURRENT_SUBSCRIPTION_ID"]}"]'
        )
    )

    azure_services = {
        VirtualMachineScheduler: os.environ["VIRTUAL_MACHINE_SCHEDULE"],
        ScaleSetScheduler: os.environ["SCALE_SET_SCHEDULE"],
        PostgresSqlScheduler: os.environ["POSTGRESQL_SCHEDULE"],
        MySqlScheduler: os.environ["MYSQL_SCHEDULE"],
        AksScheduler: os.environ["AKS_SCHEDULE"],
        ContainerGroupScheduler: os.environ["CONTAINER_GROUP_SCHEDULE"],
    }

    for subscription_id in subscription_ids:
        for service, to_schedule in azure_services.items():
            if strtobool(to_schedule):
                _azure_services = service(subscription_id)
                getattr(_azure_services, scheduler_action)(azure_tags=azure_tags)
