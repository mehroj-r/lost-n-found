from django.db.models.signals import post_save
from django.dispatch import receiver

from apps.account.models import User, UserProfile


@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):

    if created:

        # Create a UserProfile instance when a new User is created
        UserProfile.objects.create(user=instance)