from django.urls import path
from apps.account.api.views import ProfileApiView

app_name = "account"

urlpatterns = [
    path("profile/", ProfileApiView.as_view(), name="profile"),
]
