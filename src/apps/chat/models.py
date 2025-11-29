from django.db import models
from apps.core.models import TimestampedModel


class Chat(TimestampedModel):
    id = models.CharField(primary_key=True, max_length=255, unique=True)  # 'chat_<post_id>_<user1_id>_<user2_id>'
    name = models.CharField(max_length=255)
    users = models.ManyToManyField(to="account.User", related_name="chats", through="ChatUser")
    post = models.ForeignKey(to="post.Post", on_delete=models.CASCADE, related_name="chats")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name

    @staticmethod
    def generate_id(post_id: int, user_ids: list[int]) -> str:
        sorted_user_ids = sorted(user_ids)
        return f"chat_{post_id}_" + "_".join(map(str, sorted_user_ids))

class ChatUser(models.Model):
    chat = models.ForeignKey(to=Chat, on_delete=models.CASCADE, related_name="chat_users")
    user = models.ForeignKey(to="account.User", on_delete=models.CASCADE, related_name="user_chats")
    joined_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('chat', 'user')

    def __str__(self):
        return f"{self.user.get_full_name()} in {self.chat.name}"


class Message(TimestampedModel):
    chat = models.ForeignKey(to=Chat, on_delete=models.CASCADE, related_name="messages")
    sender = models.ForeignKey(to="account.User", on_delete=models.CASCADE, related_name="sent_messages")
    content = models.TextField()
    sent_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Message from {self.sender.get_full_name()} at {self.sent_at}"