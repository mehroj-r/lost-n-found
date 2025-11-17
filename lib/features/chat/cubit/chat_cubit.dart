import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/chat_details.dart';
import '../../../data/models/message.dart';
import '../../../data/repositories/chat_repository.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _chatRepository;
  Timer? _messageUpdateTimer;

  ChatCubit(this._chatRepository) : super(ChatInitial());

  Future<void> openChat(int postId) async {
    emit(ChatLoading());
    
    try {
      // Get or create chat
      final chatDetails = await _chatRepository.createOrGetChat(postId);
      
      // Load messages
      final messages = await _chatRepository.getMessages(chatDetails.chat.id);
      
      emit(ChatLoaded(
        chatDetails: chatDetails,
        messages: messages,
      ));
      
      // Start periodic message updates
      _startMessageUpdates(chatDetails.chat.id);
      
    } catch (e) {
      // Handle specific error for self-messaging
      final errorMessage = e.toString();
      if (errorMessage.contains('Cannot create chat with yourself')) {
        emit(ChatError('You cannot message your own posts'));
      } else {
        emit(ChatError(errorMessage));
      }
    }
  }

  Future<void> openChatById(String chatId) async {
    emit(ChatLoading());
    
    try {
      // Get chat details
      final chatDetails = await _chatRepository.getChatById(chatId);
      
      // Load messages
      final messages = await _chatRepository.getMessages(chatDetails.chat.id);
      
      emit(ChatLoaded(
        chatDetails: chatDetails,
        messages: messages,
      ));
      
      // Start periodic message updates
      _startMessageUpdates(chatDetails.chat.id);
      
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> sendMessage(String content) async {
    if (state is! ChatLoaded) return;
    
    final currentState = state as ChatLoaded;
    
    try {
      final newMessage = await _chatRepository.sendMessage(
        currentState.chatDetails.chat.id,
        content,
      );
      
      // Add the new message to the list (it will be at the beginning since API returns newest first)
      final updatedMessages = [newMessage, ...currentState.messages];
      
      emit(ChatLoaded(
        chatDetails: currentState.chatDetails,
        messages: updatedMessages,
      ));
      
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> refreshMessages() async {
    if (state is! ChatLoaded) return;
    
    final currentState = state as ChatLoaded;
    
    try {
      final messages = await _chatRepository.getMessages(currentState.chatDetails.chat.id);
      
      emit(ChatLoaded(
        chatDetails: currentState.chatDetails,
        messages: messages,
      ));
      
    } catch (e) {
      // Don't emit error for background refresh failures
      // Just continue with current state
    }
  }

  void _startMessageUpdates(String chatId) {
    _messageUpdateTimer?.cancel();
    
    _messageUpdateTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => refreshMessages(),
    );
  }

  void stopMessageUpdates() {
    _messageUpdateTimer?.cancel();
    _messageUpdateTimer = null;
  }

  @override
  Future<void> close() {
    stopMessageUpdates();
    return super.close();
  }
}