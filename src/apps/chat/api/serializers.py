from rest_framework import serializers
from rest_framework.fields import CurrentUserDefault

from apps.account.api.serializers import UserSerializer
from apps.chat.models import Chat, Message
from apps.post.api.serializers import PostSerializer


class ChatSerializer(serializers.ModelSerializer):
    post = PostSerializer(read_only=True)
    users = UserSerializer(read_only=True, many=True)

    class Meta:
        model = Chat
        fields = [
            'identifier',
            'post',
            'name',
            'users',
            'created_at'
        ]

        extra_kwargs = {
            'created_at': {'read_only': True},
        }

class MessageSerializer(serializers.ModelSerializer):
    sender = UserSerializer(read_only=True, default=CurrentUserDefault())

    class Meta:
        model = Message
        fields = [
            'id',
            'chat',
            'sender',
            'content',
            'sent_at',
            'created_at',
        ]

        extra_kwargs = {
            'chat': {'write_only': True},
            'content': {'required': True},
            'sent_at': {'read_only': True},
            'created_at': {'read_only': True},
        }

