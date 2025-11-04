from rest_framework import serializers

from apps.account.api.serializers import UserSerializer
from apps.post.models import Post


class PostSerializer(serializers.ModelSerializer):
    author = UserSerializer(read_only=True)

    class Meta:
        model = Post
        fields = [
            'id',
            'title',
            'description',
            'type',
            'is_completed',
            'like_count',
            'author',
            'created_at',
        ]

    def create(self, validated_data):
        validated_data['author'] = self.context['request'].user
        return super().create(validated_data)