part of 'chat_cubit.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final ChatDetails chatDetails;
  final List<Message> messages;

  const ChatLoaded({
    required this.chatDetails,
    required this.messages,
  });

  @override
  List<Object> get props => [chatDetails, messages];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}