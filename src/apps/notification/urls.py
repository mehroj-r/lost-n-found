from django.urls import include, path
from rest_framework import routers

from apps.notification.api.views import NotificationViewSet

router = routers.DefaultRouter()
router.register(r'', NotificationViewSet, basename='notification')

app_name = "notification"

urlpatterns = [
    path('', include(router.urls), name='notification'),
]