from drf_spectacular.utils import extend_schema
from rest_framework import viewsets

from apps.core.api.views.base import BaseAPIView
from apps.post.api.serializers import PostSerializer
from apps.post.models import Post


@extend_schema(tags=['post'])
class PostAPIViewSet(BaseAPIView, viewsets.ModelViewSet):
    serializer_class = PostSerializer
    queryset = Post.objects.all()

    def list(self, request, *args, **kwargs):
        self.queryset = self.queryset.select_related('author')
        return super().list(request, *args, **kwargs)