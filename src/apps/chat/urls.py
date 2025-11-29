from django.urls import include, path
from rest_framework import routers

from apps.chat.api.views import ChatViewSet

app_name = 'chat'

router = routers.DefaultRouter()
router.register('', ChatViewSet)

urlpatterns = [
    path('', include(router.urls))
]