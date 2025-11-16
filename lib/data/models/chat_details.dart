import 'package:equatable/equatable.dart';

import 'user.dart';
import 'chat.dart';
import 'post.dart';

class ChatDetails extends Equatable {
  final Chat chat;
  final List<AppUser> users;
  final Post post;

  const ChatDetails({
    required this.chat,
    required this.users,
    required this.post,
  });

  factory ChatDetails.fromJson(Map<String, dynamic> json) {
    return ChatDetails(
      chat: Chat.fromJson(json['chat'] as Map<String, dynamic>),
      users: (json['users'] as List)
          .map((user) => AppUser.fromJson(user as Map<String, dynamic>))
          .toList(),
      post: Post.fromJson(json['post'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chat': chat.toJson(),
      'users': users.map((user) => user.toJson()).toList(),
      'post': post.toJson(),
    };
  }

  @override
  List<Object?> get props => [chat, users, post];
}