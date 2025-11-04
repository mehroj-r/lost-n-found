from django.urls import path, include

app_name = "url_router"

urlpatterns = [
    path("users/", include("apps.account.urls", namespace="account")),
    path('posts/', include("apps.post.urls", namespace="post")),
    path("auth/", include("apps.core.urls.auth_urls", namespace="auth")),
    path("files/", include("apps.file.urls", namespace="files")),
    path("health/", include("apps.core.urls.health_urls", namespace="health")),
]
