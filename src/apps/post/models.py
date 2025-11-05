from django.db import models

from apps.core.models import TimestampedModel
from apps.core.utils import constants


class Post(TimestampedModel):
    title = models.CharField(max_length=255)
    description = models.CharField(max_length=4096)
    type = models.CharField(max_length=100, choices=constants.PostType)
    author = models.ForeignKey(to="account.User", on_delete=models.CASCADE, related_name="posts")
    photo = models.ForeignKey(to="file.File", on_delete=models.SET_NULL, null=True, blank=True, related_name="posts")
    is_completed = models.BooleanField(default=False)
    like_count = models.PositiveIntegerField(default=0)
    likes = models.ManyToManyField(to="account.User", related_name="liked_posts", blank=True, through="PostLikes")

    def __str__(self):
        return self.title


class PostLikes(TimestampedModel):
    user = models.ForeignKey(to="account.User", on_delete=models.CASCADE)
    post = models.ForeignKey(to="post.Post", on_delete=models.CASCADE)

    class Meta:
        unique_together = ('user', 'post')