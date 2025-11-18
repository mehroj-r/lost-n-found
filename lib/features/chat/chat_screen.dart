import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/service_locator.dart';
import '../../core/router/navigation_history.dart';
import '../../data/models/message.dart';
import '../../data/models/chat_details.dart';
import '../../features/auth/cubit/auth_cubit.dart';
import 'cubit/chat_cubit.dart';

class ChatScreen extends StatelessWidget {
  final int? postId;
  final String? chatId;

  const ChatScreen({
    super.key,
    this.postId,
    this.chatId,
  }) : assert(postId != null || chatId != null, 'Either postId or chatId must be provided');

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(ServiceLocator().chatRepository),
      child: _ChatScreenContent(postId: postId, chatId: chatId),
    );
  }
}

class _ChatScreenContent extends StatefulWidget {
  final int? postId;
  final String? chatId;

  const _ChatScreenContent({this.postId, this.chatId});

  @override
  State<_ChatScreenContent> createState() => _ChatScreenContentState();
}

class _ChatScreenContentState extends State<_ChatScreenContent> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatCubit _chatCubit;

  @override
  void initState() {
    super.initState();
    _chatCubit = context.read<ChatCubit>();
    
    // Open chat by postId or chatId
    if (widget.postId != null) {
      _chatCubit.openChat(widget.postId!);
    } else if (widget.chatId != null) {
      _chatCubit.openChatById(widget.chatId!);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _chatCubit.stopMessageUpdates();
    super.dispose();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isNotEmpty) {
      _chatCubit.sendMessage(content);
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _handleBackNavigation() {
    final navigationHistory = NavigationHistory();
    final backDestination = navigationHistory.getBackDestination();
    
    if (backDestination != null && backDestination != '/chat') {
      navigationHistory.pop();
      context.go(backDestination);
    } else {
      // Default fallback - go to chat list or home
      context.go('/chat-list');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        _handleBackNavigation();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ChatError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (widget.postId != null) {
                        _chatCubit.openChat(widget.postId!);
                      } else if (widget.chatId != null) {
                        _chatCubit.openChatById(widget.chatId!);
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ChatLoaded) {
            return Column(
              children: [
                _buildAppBar(state.chatDetails),
                _buildPostCard(state.chatDetails),
                Expanded(
                  child: _buildMessagesList(state.messages),
                ),
                _buildMessageInput(),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
      ),
    );
  }

  Widget _buildAppBar(ChatDetails chatDetails) {
    // Get the current authenticated user
    final authState = context.read<AuthCubit>().state;
    final currentUserId = authState.user?.id;
    
    // Find the other user (not the current authenticated user)
    final otherUser = chatDetails.users.firstWhere(
      (user) => user.id != currentUserId,
      orElse: () => chatDetails.users.first, // Fallback to first user
    );

    return Container(
      padding: EdgeInsets.fromLTRB(8, MediaQuery.of(context).padding.top + 8, 16, 16),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            onPressed: () => _handleBackNavigation(),
            icon: const Icon(Icons.arrow_back_ios_rounded),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).primaryColor.withAlpha(51),
            ),
            child: otherUser.avatar?.url != null && otherUser.avatar!.url.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      otherUser.avatar!.url,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildAvatarFallback(otherUser),
                    ),
                  )
                : _buildAvatarFallback(otherUser),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${otherUser.firstName} ${otherUser.lastName}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '@${otherUser.username}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(dynamic user) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withAlpha(204),
            Theme.of(context).primaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          user.firstName[0].toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(ChatDetails chatDetails) {
    final post = chatDetails.post;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: post.photo?.url != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      post.photo!.url,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildPostImageFallback(),
                    ),
                  )
                : _buildPostImageFallback(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        post.location,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: post.type == 'lost' 
                        ? Colors.red.withAlpha(26) 
                        : Colors.blue.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    post.type == 'lost' ? 'Lost Item' : 'Found Item',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: post.type == 'lost' ? Colors.red : Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostImageFallback() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.image_outlined,
        color: Colors.grey[400],
        size: 24,
      ),
    );
  }

  Widget _buildMessagesList(List<Message> messages) {
    if (messages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            Text(
              'Start the conversation!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true, // Show newest messages at bottom
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 16), // Reduced right padding
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isOutgoing = message.displayType == 'outgoing';
        
        return _buildMessageBubble(message, isOutgoing);
      },
    );
  }

  Widget _buildMessageBubble(Message message, bool isOutgoing) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isOutgoing ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isOutgoing) ...[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor.withAlpha(51),
              ),
              child: message.sender.avatar?.url != null
                  ? ClipOval(
                      child: Image.network(
                        message.sender.avatar!.url,
                        width: 34,
                        height: 34,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Text(
                            message.sender.firstName[0].toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        message.sender.firstName[0].toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            flex: 1,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75, // Max 75% of screen width
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isOutgoing 
                      ? Theme.of(context).primaryColor 
                      : Colors.white,
                  borderRadius: BorderRadius.circular(18).copyWith(
                    bottomLeft: isOutgoing ? const Radius.circular(18) : const Radius.circular(4),
                    bottomRight: isOutgoing ? const Radius.circular(4) : const Radius.circular(18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.content,
                      style: TextStyle(
                        color: isOutgoing ? Colors.white : Colors.black87,
                        fontSize: 15,
                        height: 1.4,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    _getTimeAgo(message.createdAt),
                    style: TextStyle(
                      color: isOutgoing 
                          ? Colors.white.withAlpha(179)
                          : Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ),
          // Add space only on the left side for incoming messages
          if (!isOutgoing) const SizedBox(width: 28),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 120, // Limit maximum height of input field
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  maxLines: 5,  // Limit to 5 lines maximum
                  minLines: 1,  // Start with 1 line
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}