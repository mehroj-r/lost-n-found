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
}