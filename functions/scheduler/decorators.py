"""Decorators module for scheduler handlers."""

import functools
import logging
import os


def dry_run_aware(func):
    """Skip the actual operation and log instead when dry-run mode is enabled.

    Reads the SCHEDULER_DRY_RUN environment variable. When set to "true",
    the decorated _perform_action method will only log the intended action
    without executing it.

    :param func: The _perform_action method to wrap
    :return: Wrapped function
    """

    @functools.wraps(func)
    def wrapper(self, resource_id, action, operation):
        if os.environ.get("SCHEDULER_DRY_RUN", "false").lower() == "true":
            logging.info("[DRY-RUN] Would %s: %s", action, resource_id)
            return
        return func(self, resource_id, action, operation)

    return wrapper
