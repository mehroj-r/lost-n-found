from django.db import models

from apps.account.models import User
from apps.core.models import TimestampedModel
from apps.core.utils.constants import NotificationType


class Notification(TimestampedModel):
    users = models.ManyToManyField(to="account.User", related_name="notifications", through="NotificationUser")
    title = models.CharField(max_length=255)
    message = models.TextField()
    type = models.CharField(max_length=100, choices=NotificationType.choices, default=NotificationType.MESSAGE)

    def __str__(self):
        return f"Notification {self.id} - {self.type}"


class NotificationUser(models.Model):
    user = models.OneToOneField(to=User, on_delete=models.CASCADE)
    notification = models.ForeignKey(to=Notification, on_delete=models.CASCADE)
    is_read = models.BooleanField(default=False)
