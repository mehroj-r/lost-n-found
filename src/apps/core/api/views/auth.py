from drf_spectacular.utils import extend_schema
from rest_framework_simplejwt.serializers import TokenVerifySerializer
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
    TokenVerifyView,
)

from apps.core.api.views.base import BaseAPIView


@extend_schema(tags=['auth'])
class LoginAPIView(TokenObtainPairView, BaseAPIView):
    pass


@extend_schema(tags=['auth'])
class RefreshAPIView(TokenRefreshView, BaseAPIView):
    pass


@extend_schema(tags=['auth'])
class TokenVerifyAPIView(TokenVerifyView, BaseAPIView):

    def post(self, request, *args, **kwargs):
        response = super().post(request, *args, **kwargs)

        # If the token is valid, return a custom success message
        if response.status_code == 200:
            serializer = TokenVerifySerializer(data=request.data)
            serializer.is_valid(raise_exception=True)
            response.data = {"detail": "Token is valid"}

        return response
