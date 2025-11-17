import 'package:equatable/equatable.dart';

import 'post.dart';
import 'chat.dart';

class ChatListItem extends Equatable {
  final Chat chat;
  final Post post;

  const ChatListItem({
    required this.chat,
    required this.post,
  });

  factory ChatListItem.fromJson(Map<String, dynamic> json) {
    return ChatListItem(
      chat: Chat.fromJson({
        'id': json['id'],
        'name': json['name'],
        'created_at': json['created_at'],
      }),
      post: Post.fromJson(json['post'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': chat.id,
      'name': chat.name,
      'post': post.toJson(),
      'created_at': chat.createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [chat, post];
}