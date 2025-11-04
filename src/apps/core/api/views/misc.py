from rest_framework import generics
from rest_framework.response import Response


class HealthAPIView(generics.RetrieveAPIView):
    permission_classes = []
    serializer_class = None

    def retrieve(self, request, *args, **kwargs):
        return Response(data={"status": "ok"}, status=200)