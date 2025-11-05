from drf_spectacular.utils import extend_schema
from rest_framework import permissions

from apps.account.models import User
from apps.core.api.views import base as core_views
from apps.account.api import serializers as account_ser

@extend_schema(tags=['auth'])
class RegisterApiView(core_views.CreateAPIView):
    serializer_class = account_ser.UserRegisterSerializer
    permission_classes = [permissions.AllowAny]
    queryset = User.objects.all()


@extend_schema(tags=['user'])
class ProfileApiView(core_views.RetrieveAPIView, core_views.UpdateAPIView):
    serializer_class = account_ser.UserProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user