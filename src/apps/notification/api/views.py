from django.db.models import Q, Case, When, BooleanField
from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response

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
        ).annotate(
            is_read=Case(
                When(
                    Q(notificationuser__user=request.user, notificationuser__is_read=True),
                    then=True
                ),
                default=False,
                output_field=BooleanField()
            )
        ).order_by('-created_at')
        return super().list(request, *args, **kwargs)


    @action(methods=['POST'], detail=True, url_path='read', url_name='read_notification')
    def read(self, request, *args, **kwargs):
        notification = self.get_object()
        notification_user, created = notification.notificationuser_set.get_or_create(user=request.user)
        notification_user.is_read = True
        notification_user.save()
        return Response({'detail': 'Notification marked as read.'}, status=status.HTTP_200_OK)


    @action(methods=['POST'], detail=False, url_path='read-all', url_name='read_all_notifications')
    def read_all(self, request, *args, **kwargs):
        notifications = self.get_queryset().filter(
            Q(users=request.user) | Q(broadcast_type=NotificationBroadcast.ALL)
        )
        for notification in notifications:
            notification_user, created = notification.notificationuser_set.get_or_create(user=request.user)
            notification_user.is_read = True
            notification_user.save()
        return Response({'detail': 'All notifications marked as read.'}, status=status.HTTP_200_OK)
