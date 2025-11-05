from rest_framework import serializers

from apps.account.models import User
from apps.file.models import File


class UserRegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ("id", "phone", "username", "email", "first_name", "last_name", "patronymic", 'gender', "password")
        extra_kwargs = {
            "username": {"required": False},
            "last_name": {"required": False},
            "patronymic": {"required": False},
        }


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ("id", "phone", "username", "email", "first_name", "last_name", "patronymic", 'gender')


class UserProfileSerializer(serializers.ModelSerializer):
    bio = serializers.CharField(source='profile.bio')
    fio = serializers.CharField(source='get_full_name')
    avatar = serializers.PrimaryKeyRelatedField(source='profile.avatar', queryset=File.objects.all())

    class Meta:
        model = User
        fields = (
            "id",
            "phone",
            "username",
            "email",
            "first_name",
            "last_name",
            "patronymic",
            'gender',
            'bio',
            'fio',
            'avatar',
        )

        extra_kwargs = {
            "last_name": {"required": False},
            "patronymic": {"required": False},
            'avatar': {'required': False, 'allow_null': True},
            'bio': {'required': False, 'allow_null': True},
            'gender': {'required': False},
            'fio': {'read_only': True},
            'email': {'required': False},
        }

    def update(self, instance, validated_data):
        profile_data = {
            'bio': validated_data.get('profile', {}).get('bio', instance.profile.bio),
            'avatar': validated_data.pop('profile', {}).get('avatar', instance.profile.avatar),
        }

        # Update user instance
        for key, value in validated_data.items():
            setattr(instance, key, value)
        instance.save()

        # Update profile instance
        profile = instance.profile
        for key, value in profile_data.items():
            setattr(profile, key, value)
        profile.save()

        return instance

    def to_representation(self, instance):
        representation = super().to_representation(instance)
        # Add avatar URL if avatar exists
        avatar = instance.profile.avatar
        if avatar:
            representation['avatar'] = avatar.url
        return representation