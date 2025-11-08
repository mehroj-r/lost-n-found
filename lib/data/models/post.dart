class Post {
  final String id;
  final String title;
  final String description;
  final String photo;
  final List<String> tags;
  final String type;  // 'lost', 'found'
  final String author;
  final String location;
  final int likeCount;
  final bool isLiked;
  final bool isCompleted;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.title,
    required this.description,
    required this.photo,
    required this.tags,
    required this.type,
    required this.author,
    required this.location,
    required this.likeCount,
    required this.isLiked,
    required this.isCompleted,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      photo: json['photo']?.toString() ?? json['photoUrl']?.toString() ?? '',
      tags: json['tags'] != null 
          ? List<String>.from(json['tags'] as List)
          : [],
      type: json['type']?.toString() ?? json['category']?.toString() ?? 'lost',
      author: json['author']?.toString() ?? json['authorName']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      likeCount: json['likeCount'] ?? json['likes'] ?? 0,
      isLiked: json['isLiked'] ?? json['is_liked'] ?? false,
      isCompleted: json['isCompleted'] ?? json['is_completed'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'photo': photo,
      'tags': tags,
      'type': type,
      'author': author,
      'location': location,
      'likeCount': likeCount,
      'isLiked': isLiked,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}