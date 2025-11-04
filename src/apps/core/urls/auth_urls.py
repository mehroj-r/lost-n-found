from django.urls import path

from apps.account.api.views import RegisterApiView
from apps.core.api.views.auth import LoginAPIView, RefreshAPIView, TokenVerifyAPIView

app_name = "auth"

urlpatterns = [
    path("login/", LoginAPIView.as_view(), name="login"),
    path("register/", RegisterApiView.as_view(), name="register"),
    path("refresh/", RefreshAPIView.as_view(), name="token_refresh"),
    path("verify/", TokenVerifyAPIView.as_view(), name="token_verify"),
]
