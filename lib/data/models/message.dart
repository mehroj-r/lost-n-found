import 'package:equatable/equatable.dart';

import 'user.dart';

class Message extends Equatable {
  final int id;
  final AppUser sender;
  final String content;
  final String displayType; // "outgoing" or "incoming"
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.sender,
    required this.content,
    required this.displayType,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int,
      sender: AppUser.fromJson(json['sender'] as Map<String, dynamic>),
      content: json['content'] as String,
      displayType: json['display_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender.toJson(),
      'content': content,
      'display_type': displayType,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, sender, content, displayType, createdAt];
}