from django.db import transaction
from drf_spectacular.utils import extend_schema
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response

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

    @transaction.atomic
    @action(methods=['POST', 'DELETE'], detail=True, url_path='likes', url_name='like_post')
    def like_post(self, request, pk=None):

        if request.method == 'DELETE':
            return self._unlike_post(request, pk)
        elif request.method == 'POST':
            return self._like_post(request, pk)
        else:
            return Response({'detail': 'Method not allowed.'}, status=status.HTTP_405_METHOD_NOT_ALLOWED)


    def _like_post(self, request, pk=None):
        post = self.get_object()
        post.likes.add(request.user)
        post.like_count += post.likes.count()
        post.save()
        serializer = self.get_serializer(post)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    def _unlike_post(self, request, pk=None):
        post = self.get_object()
        post.likes.remove(request.user)
        post.like_count = post.likes.count()
        post.save()
        serializer = self.get_serializer(post)
        return Response(serializer.data, status=status.HTTP_204_NO_CONTENT)