from rest_framework import serializers

from apps.account.api.serializers import UserSerializer
from apps.file.api.serializers import FileSerializer
from apps.post.models import Post


class PostSerializer(serializers.ModelSerializer):
    author = UserSerializer(read_only=True)
    is_liked = serializers.SerializerMethodField()

    class Meta:
        model = Post
        fields = [
            'id',
            'photo',
            'title',
            'description',
            'tags',
            'location',
            'type',
            'is_completed',
            'like_count',
            'is_liked',
            'author',
            'created_at',
        ]

        extra_kwargs = {
            'photo': {'required': True, 'allow_null': False, 'allow_blank': False},
            'tags': {'required': False},
            'location': {'required': True, 'allow_null': False, 'allow_blank': False},
            'like_count': {'read_only': True},
            'is_liked': {'read_only': True},
            'created_at': {'read_only': True},
        }

    def create(self, validated_data):
        validated_data['author'] = self.context['request'].user
        return super().create(validated_data)

    def get_is_liked(self, obj):
        user = self.context['request'].user
        if user.is_anonymous:
            return False
        return obj.likes.filter(id=user.id).exists()

    def to_representation(self, instance):
        representation = super().to_representation(instance)
        if instance.photo:
            representation['photo'] = FileSerializer(instance.photo, context=self.context).data
        else:
            representation['photo'] = None
        return representation