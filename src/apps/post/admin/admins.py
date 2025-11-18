from django.contrib import admin
from unfold.admin import ModelAdmin
from apps.post.models import Post


@admin.register(Post)
class PostAdmin(ModelAdmin):
    list_display = ("id", "title", "author", "created_at", "updated_at")
    search_fields = ("title", "author__username")
    list_filter = ("created_at", "updated_at")
    ordering = ("-created_at",)