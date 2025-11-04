from drf_spectacular.utils import extend_schema
from rest_framework import status
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from apps.core.api.views.base import CreateAPIView
from apps.file.api.serializers import FileSerializer


@extend_schema(tags=['file'])
class UploadFileAPIView(CreateAPIView):
    parser_classes = (MultiPartParser, FormParser)
    permission_classes = (IsAuthenticated,)

    def post(self, request, *args, **kwargs):
        file_serializer = FileSerializer(data=request.data)
        file_serializer.is_valid(raise_exception=True)
        file_serializer.save()
        return Response(data=file_serializer.data, status=status.HTTP_201_CREATED)