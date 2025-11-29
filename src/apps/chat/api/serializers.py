from rest_framework import serializers
from rest_framework.fields import CurrentUserDefault

from apps.account.api.serializers import UserSerializer
from apps.chat.models import Chat, Message
from apps.post.api.serializers import PostSerializer


class MessageSerializer(serializers.ModelSerializer):
    sender = UserSerializer(read_only=True, default=CurrentUserDefault())
    display_type = serializers.SerializerMethodField()

    class Meta:
        model = Message
        fields = [
            'id',
            'chat',
            'sender',
            'content',
            'display_type',
            'created_at',
        ]

        extra_kwargs = {
            'chat': {'write_only': True},
            'content': {'required': True},
            'created_at': {'read_only': True},
        }

    def get_display_type(self, obj):
        user = self.context['request'].user
        return 'outgoing' if obj.sender == user else 'incoming'


class ChatListSerializer(serializers.ModelSerializer):
    post = PostSerializer(read_only=True)
    last_message = MessageSerializer(source='get_last_message', read_only=True)

    class Meta:
        model = Chat
        fields = [
            'id',
            'name',
            'post',
            'last_message',
            'created_at'
        ]

        extra_kwargs = {
            'created_at': {'read_only': True},
        }


class ChatSerializer(serializers.ModelSerializer):
    post = PostSerializer(read_only=True)
    users = UserSerializer(read_only=True, many=True)

    class Meta:
        model = Chat
        fields = [
            'id',
            'post',
            'name',
            'users',
            'created_at'
        ]

        extra_kwargs = {
            'created_at': {'read_only': True},
        }