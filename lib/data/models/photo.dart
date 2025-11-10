class Photo {
  final int id;
  final String url;
  final int size;
  final String name;
  final String extension;
  final DateTime createdAt;

  Photo({
    required this.id,
    required this.url,
    required this.size,
    required this.name,
    required this.extension,
    required this.createdAt,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'] ?? 0,
      url: json['url']?.toString() ?? '',
      size: json['size'] ?? 0,
      name: json['name']?.toString() ?? '',
      extension: json['extension']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'size': size,
      'name': name,
      'extension': extension,
      'created_at': createdAt.toIso8601String(),
    };
  }
}