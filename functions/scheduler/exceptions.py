"""Exception function for all Azure scheduler."""

import logging


def azure_exceptions(resource_name: str, resource_id: str, exception) -> None:
    """Exception raised during execution of scale set scheduler.

    Log scale set exceptions on the specific Azure resources.

    :param str resource_name:
        Aws resource name
    :param str resource_id:
        Aws resource id
    :param str exception:
        Human readable string describing the exception
    """
    exception_code = type(exception).__name__

    info_codes = ["ResourceNotFoundError"]
    warning_codes = [
        "ResourceExistsError",
        "HttpResponseError",
        "ResourceModifiedError",
    ]

    if exception_code in info_codes:
        logging.info(
            "%s %s: %s",
            resource_name,
            resource_id,
            exception,
        )
    elif exception_code in warning_codes:
        logging.warning(
            "%s %s: %s",
            resource_name,
            resource_id,
            exception,
        )
    else:
        logging.error(
            "Unexpected error on %s %s: %s",
            resource_name,
            resource_id,
            exception,
        )
