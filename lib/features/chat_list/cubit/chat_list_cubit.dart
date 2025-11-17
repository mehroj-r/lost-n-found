import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/chat_list_item.dart';
import '../../../data/repositories/chat_repository.dart';

part 'chat_list_state.dart';

class ChatListCubit extends Cubit<ChatListState> {
  final ChatRepository _chatRepository;

  ChatListCubit(this._chatRepository) : super(ChatListInitial());

  Future<void> loadUserChats() async {
    emit(ChatListLoading());
    
    try {
      final chats = await _chatRepository.getUserChats();
      emit(ChatListLoaded(chats));
    } catch (e) {
      emit(ChatListError(e.toString()));
    }
  }

  Future<void> refreshChats() async {
    try {
      final chats = await _chatRepository.getUserChats();
      emit(ChatListLoaded(chats));
    } catch (e) {
      emit(ChatListError(e.toString()));
    }
  }
}