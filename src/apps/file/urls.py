from django.urls import path

from .api import views

app_name = "files"

urlpatterns = (
    path("", views.UploadFileAPIView.as_view(), name="upload"),
)
