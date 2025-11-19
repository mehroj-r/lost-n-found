import 'user.dart';
import 'photo.dart';

class Post {
  final int id;
  final String title;
  final String description;
  final Photo? photo;
  final List<String> tags;
  final String type; // 'lost', 'found'
  final AppUser author;
  final String location;
  final int likeCount;
  final bool isLiked;
  final bool isCompleted;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.title,
    required this.description,
    this.photo,
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
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      photo: json['photo'] != null ? Photo.fromJson(json['photo']) : null,
      tags: json['tags'] != null ? List<String>.from(json['tags'] as List) : [],
      type: json['type']?.toString() ?? 'lost',
      author: AppUser.fromJson(json['author'] ?? {}),
      location: json['location']?.toString() ?? '',
      likeCount: json['like_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      isCompleted: json['is_completed'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'photo': photo?.toJson(),
      'tags': tags,
      'type': type,
      'author': author.toJson(),
      'location': location,
      'like_count': likeCount,
      'is_liked': isLiked,
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // NEW:
  Post copyWith({
    String? title,
    String? description,
    Photo? photo,
    List<String>? tags,
    String? type,
    AppUser? author,
    String? location,
    int? likeCount,
    bool? isLiked,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Post(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      photo: photo ?? this.photo,
      tags: tags ?? this.tags,
      type: type ?? this.type,
      author: author ?? this.author,
      location: location ?? this.location,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
