import 'package:equatable/equatable.dart';

import 'post.dart';
import 'chat.dart';
import 'message.dart';
import 'user.dart';

class ChatListItem extends Equatable {
  final Chat chat;
  final Post post;
  final Message? lastMessage;
  final AppUser participant; // The other user in the chat

  const ChatListItem({
    required this.chat,
    required this.post,
    this.lastMessage,
    required this.participant,
  });

  factory ChatListItem.fromJson(Map<String, dynamic> json) {
    return ChatListItem(
      chat: Chat.fromJson({
        'id': json['id'],
        'name': json['name'],
        'created_at': json['created_at'],
      }),
      post: Post.fromJson(json['post'] as Map<String, dynamic>),
      participant: AppUser.fromJson(json['participant'] as Map<String, dynamic>),
      lastMessage: json['last_message'] != null 
          ? Message.fromJson(json['last_message'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': chat.id,
      'name': chat.name,
      'post': post.toJson(),
      'participant': participant.toJson(),
      'created_at': chat.createdAt.toIso8601String(),
      'last_message': lastMessage?.toJson(),
    };
  }

  @override
  List<Object?> get props => [chat, post, lastMessage, participant];
}