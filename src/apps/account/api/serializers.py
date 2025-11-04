from rest_framework import serializers

from apps.account.models import User


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