import 'package:equatable/equatable.dart';

class Chat extends Equatable {
  final String id;
  final String name;
  final DateTime createdAt;

  const Chat({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, name, createdAt];
}