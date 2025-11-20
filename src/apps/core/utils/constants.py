from django.db.models import TextChoices


class PostType(TextChoices):
    LOST = ("lost", "Lost")
    FOUND = ("found", "Found")


class NotificationType(TextChoices):
    MESSAGE = ("message", "Message")
    ALERT = ("alert", "Alert")
    REMINDER = ("reminder", "Reminder")