from django.contrib import admin
from unfold.admin import ModelAdmin, TabularInline

from apps.notification.models import Notification


class NotificationUserInline(TabularInline):
    model = Notification.users.through
    extra = 1
    autocomplete_fields = ['user']
    verbose_name = "User"
    verbose_name_plural = "Users"


@admin.register(Notification)
class NotificationAdmin(ModelAdmin):
    list_display = ("id", "title", "type", "broadcast_type", "created_at")
    list_filter = ("created_at",)
    search_fields = ("message",)
    ordering = ("-created_at",)
    readonly_fields = ("created_at", "updated_at")

    inlines = [NotificationUserInline]

    fieldsets = (
        (None, {
            "fields": ("title", "message", "type", "broadcast_type")
        }),
    )