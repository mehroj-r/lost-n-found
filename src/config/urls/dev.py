from django.conf import settings
from django.conf.urls.static import static

if settings.DEBUG:
    from debug_toolbar.toolbar import debug_toolbar_urls
    from django.urls import path, include
    from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView

    urlpatterns = [
        path("api-auth/", include("rest_framework.urls")),
        path('schema/', SpectacularAPIView.as_view(), name='schema'),
        path('schema/swagger/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
        *debug_toolbar_urls(),  # Django Debug Toolbar URLs
        *static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT) # Serving media files in development
    ]
