part of 'chat_list_cubit.dart';

abstract class ChatListState extends Equatable {
  const ChatListState();

  @override
  List<Object> get props => [];
}

class ChatListInitial extends ChatListState {}

class ChatListLoading extends ChatListState {}

class ChatListLoaded extends ChatListState {
  final List<ChatListItem> chats;

  const ChatListLoaded(this.chats);

  @override
  List<Object> get props => [chats];
}

class ChatListError extends ChatListState {
  final String message;

  const ChatListError(this.message);

  @override
  List<Object> get props => [message];
}