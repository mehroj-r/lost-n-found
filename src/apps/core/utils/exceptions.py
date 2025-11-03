from rest_framework import status
from rest_framework.exceptions import APIException


class CustomValidationError(APIException):
    default_detail = "Validation error"
    default_code = "validation_error"

    def __init__(
        self,
        msg=default_detail,
        status_code: int = status.HTTP_400_BAD_REQUEST,
        code: str = default_code,
    ):
        self.status_code = status_code
        self.detail = msg
        self.code = code