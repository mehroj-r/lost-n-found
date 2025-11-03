from django.contrib import admin
from unfold.admin import ModelAdmin

from apps.file.models import File


@admin.register(File)
class FileAdmin(ModelAdmin):
    list_display = ("id", "file")
    list_display_links = ("id", "file")
