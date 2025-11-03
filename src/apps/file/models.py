from contextlib import suppress

from django.conf import settings
from django.db import models

from apps.core.models import TimestampedModel
from apps.core.utils.exceptions import CustomValidationError


class File(TimestampedModel):
    """For upload static files"""

    file = models.FileField(upload_to="files/%Y/%m/%d")
    name = models.CharField(max_length=1024, blank=True)
    extension = models.CharField(max_length=16, blank=True)
    size = models.PositiveIntegerField(blank=True, null=True)

    @property
    def url(self):
        if self.file:
            file_url = getattr(self.file, "url")
            if settings.USE_S3:
                return file_url

            return f"{settings.BASE_URL}{file_url}" if self.file else None

    def to_dict(self):
        if settings.USE_S3:
            return {"id": self.id, "url": self.url, "path": self.file.name}
        return {"id": self.id, "url": self.url, "path": self.url}

    def save(self, *args, **kwargs):

        self.name = self.file.name
        self.extension = self.name.split(".")[-1]

        if self.extension not in ["jpg", "jpeg", "png", "webp"]:
            raise CustomValidationError(f"File extension {self.extension} not supported")

        with suppress(Exception):
            self.size = self.file.size

        super().save(*args, **kwargs)

    def __str__(self):
        return f"file object {self.id} -> {self.name}"
