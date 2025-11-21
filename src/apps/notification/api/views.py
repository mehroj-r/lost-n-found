from django.db.models import Q
from rest_framework import viewsets, permissions

from apps.core.api.views.base import BaseAPIView
from apps.core.utils.constants import NotificationBroadcast
from apps.notification.api.serializers import NotificationSerializer
from apps.notification.models import Notification


class NotificationViewSet(BaseAPIView, viewsets.ModelViewSet):
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]
    queryset = Notification.objects.all()

    def list(self, request, *args, **kwargs):
        self.queryset = self.get_queryset().filter(
            Q(users=request.user) | Q(broadcast_type=NotificationBroadcast.ALL)
        ).order_by('-created_at')
        return super().list(request, *args, **kwargs)
