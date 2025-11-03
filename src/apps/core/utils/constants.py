from django.db.models import TextChoices


class PostType(TextChoices):
    lost = ("lost", "Lost")
    found = ("found", "Found")