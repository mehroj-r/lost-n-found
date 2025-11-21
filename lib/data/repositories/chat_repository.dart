import '../../core/network/dio_client.dart';
import '../../core/config/api_config.dart';
import '../models/chat_details.dart';
import '../models/message.dart';
import '../models/chat_list_item.dart';

abstract class ChatRepository {
  Future<ChatDetails> createOrGetChat(int postId);
  Future<ChatDetails> getChatById(String chatId);
  Future<List<Message>> getMessages(String chatId);
  Future<Message> sendMessage(String chatId, String content);
  Future<List<ChatListItem>> getUserChats();
}

class ApiChatRepository implements ChatRepository {
  final DioClient _dioClient;

  ApiChatRepository(this._dioClient);

  @override
  Future<ChatDetails> createOrGetChat(int postId) async {
    try {
      final response = await _dioClient.get('${ApiConfig.chatCreate}$postId/message/');
      
      final data = response.data;
      if (data is Map && data['success'] == true && data.containsKey('data')) {
        return ChatDetails.fromJson(data['data']);
      }
      
      throw Exception(data['message'] ?? 'Failed to create or get chat');
    } catch (e) {
      throw Exception('Failed to create or get chat: $e');
    }
  }

  @override
  Future<ChatDetails> getChatById(String chatId) async {
    try {
      final response = await _dioClient.get('${ApiConfig.chatGet}$chatId');
      
      final data = response.data;
      if (data is Map && data['success'] == true && data.containsKey('data')) {
        return ChatDetails.fromJson(data['data']);
      }
      
      throw Exception(data['message'] ?? 'Failed to get chat');
    } catch (e) {
      throw Exception('Failed to get chat: $e');
    }
  }

  @override
  Future<List<Message>> getMessages(String chatId) async {
    try {
      final response = await _dioClient.get('${ApiConfig.chatMessages}$chatId/messages');
      
      final data = response.data;
      if (data is Map && data['success'] == true && data.containsKey('data')) {
        final messagesList = data['data'] as List;
        return messagesList
            .map((json) => Message.fromJson(json))
            .toList();
      }
      
      throw Exception(data['message'] ?? 'Failed to get messages');
    } catch (e) {
      throw Exception('Failed to get messages: $e');
    }
  }

  @override
  Future<Message> sendMessage(String chatId, String content) async {
    try {
      final response = await _dioClient.post(
        '${ApiConfig.chatSendMessage}$chatId/message',
        data: {
          'content': content,
        },
      );
      
      final data = response.data;
      if (data is Map && data['success'] == true && data.containsKey('data')) {
        return Message.fromJson(data['data']);
      }
      
      throw Exception(data['message'] ?? 'Failed to send message');
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  @override
  Future<List<ChatListItem>> getUserChats() async {
    try {
      final response = await _dioClient.get(ApiConfig.chatsList);
      
      final data = response.data;
      if (data is Map && data['success'] == true && data.containsKey('data')) {
        final chatsList = data['data'] as List;
        return chatsList
            .map((json) => ChatListItem.fromJson(json))
            .toList();
      }
      
      throw Exception(data['message'] ?? 'Failed to get user chats');
    } catch (e) {
      throw Exception('Failed to get user chats: $e');
    }
  }
}