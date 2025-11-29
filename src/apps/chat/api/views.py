from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from apps.chat.api.serializers import ChatSerializer, MessageSerializer, ChatListSerializer
from apps.chat.models import Chat
from apps.core.api.views.base import BaseAPIView


class ChatViewSet(BaseAPIView, viewsets.ModelViewSet):
    serializer_class = ChatSerializer
    queryset = Chat.objects.all()
    permission_classes = [IsAuthenticated]

    def get_serializer_class(self):
        if self.action == 'list':
            return ChatListSerializer

        return ChatSerializer

    def get_queryset(self):
        user = self.request.user
        return self.queryset.filter(users=user).distinct()

    def retrieve(self, request, *args, **kwargs):
        chat = self.get_object()
        chat_data = self.get_serializer(chat, context={'request': request}).data
        post_data = chat_data.pop('post', None)
        users_data = chat_data.pop('users', None)

        return Response(
            {
                'chat': chat_data,
                'users': users_data,
                'post': post_data
            },
            status=status.HTTP_200_OK
        )
    @action(methods=['GET', 'POST'], detail=True, url_path='messages', url_name='chat_messages')
    def messages(self, request, pk=None):

        handlers = {
            'GET': self._list_messages,
            'POST': self._create_message
        }

        return handlers[request.method].__call__(request, pk)

    def _list_messages(self, request, pk=None):
        chat = self.get_object()
        messages = chat.messages.all().order_by('-created_at')
        page = self.paginate_queryset(messages)
        if page is not None:
            serializer = MessageSerializer(page, many=True, context={'request': request})
            return self.get_paginated_response(serializer.data)
        serializer = MessageSerializer(messages, many=True, context={'request': request})
        return Response(serializer.data, status=status.HTTP_200_OK)

    def _create_message(self, request, pk=None):
        chat = self.get_object()
        data = {
            **request.data,
            'chat': chat.id
        }
        serializer = MessageSerializer(data=data, context={'request': request})
        serializer.is_valid(raise_exception=True)
        serializer.save(sender=request.user)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
