from django.urls import path, include
from rest_framework import routers

from apps.post.api.views import PostAPIViewSet

app_name = "post"

router = routers.DefaultRouter()
router.register('', PostAPIViewSet, basename='post')

urlpatterns = [
    path('', include(router.urls)),
]
