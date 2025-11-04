import os
from datetime import timedelta
from .base import *


if DEBUG:
    INSTALLED_APPS += ["debug_toolbar", "django_extensions", "query_counter", "drf_spectacular"]

    MIDDLEWARE += [
        "debug_toolbar.middleware.DebugToolbarMiddleware",
        "query_counter.middleware.DjangoQueryCounterMiddleware",
    ]

    INTERNAL_IPS = ["127.0.0.1"]

    SIMPLE_JWT = {
        "ACCESS_TOKEN_LIFETIME": timedelta(days=1),
        "REFRESH_TOKEN_LIFETIME": timedelta(days=7),
        "ROTATE_REFRESH_TOKENS": True,
        "BLACKLIST_AFTER_ROTATION": True,
        "AUTH_HEADER_TYPES": ("Bearer",),
    }

    SPECTACULAR_SETTINGS = {
        'TITLE': 'Deepwell service',
        'DESCRIPTION': '',
        'VERSION': '1.0.0',
        'SERVE_INCLUDE_SCHEMA': False,
        'DEFAULT_GENERATOR_CLASS': 'drf_spectacular.generators.SchemaGenerator',
        'SWAGGER_UI_DIST': 'https://cdn.jsdelivr.net/npm/swagger-ui-dist@latest',
        'SERVE_AUTHENTICATION': None,
        'COMPONENT_SPLIT_REQUEST': True,
        "FILTER_INSPECTORS": [
            "drf_spectacular.contrib.django_filters.DjangoFilterInspector",
        ],
    }

    REST_FRAMEWORK['DEFAULT_SCHEMA_CLASS'] = 'drf_spectacular.openapi.AutoSchema'

    CORS_ALLOW_ALL_ORIGINS = True
