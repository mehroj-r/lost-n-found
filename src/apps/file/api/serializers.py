from rest_framework import serializers

from apps.file.models import File


class FileSerializer(serializers.ModelSerializer):
    type = serializers.CharField(source="file_type", read_only=True)

    class Meta:
        model = File
        fields = (
            "id",
            "url",
            "file",
            "type",
            "size",
            "name",
            "extension",
            "created_at",
        )
        extra_kwargs = {
            "file": {"write_only": True},
            "name": {"read_only": True},
            "size": {"read_only": True},
            "created_at": {"read_only": True},
        }