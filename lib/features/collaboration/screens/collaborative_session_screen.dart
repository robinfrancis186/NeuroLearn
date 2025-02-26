import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/collaborative_provider.dart';
import '../../../theme/app_colors.dart';

class CollaborativeSessionScreen extends StatefulWidget {
  final String sessionId;

  const CollaborativeSessionScreen({
    super.key,
    required this.sessionId,
  });

  @override
  State<CollaborativeSessionScreen> createState() => _CollaborativeSessionScreenState();
}

class _CollaborativeSessionScreenState extends State<CollaborativeSessionScreen> {
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _joinSession();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _leaveSession();
    super.dispose();
  }

  Future<void> _joinSession() async {
    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<CollaborativeProvider>(context, listen: false);
      await provider.joinSession(widget.sessionId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to join session')),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _leaveSession() async {
    try {
      final provider = Provider.of<CollaborativeProvider>(context, listen: false);
      await provider.leaveSession(widget.sessionId);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<CollaborativeProvider>(context, listen: false);
      await provider.sendMessage(widget.sessionId, message);
      _messageController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send message')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<CollaborativeProvider>(
          builder: (context, provider, child) {
            final session = provider.currentSession;
            return Text(session?.name ?? 'Loading...');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () => _showParticipants(context),
          ),
        ],
      ),
      body: Consumer<CollaborativeProvider>(
        builder: (context, provider, child) {
          final session = provider.currentSession;
          if (session == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: _buildMessageList(session.messages),
              ),
              _buildMessageInput(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageList(List<CollaborativeMessage> messages) {
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: AppColors.primary.withAlpha(100),
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start the conversation!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isCurrentUser = message.senderId == Provider.of<CollaborativeProvider>(context, listen: false).currentUserId;

        return Align(
          alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isCurrentUser ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isCurrentUser)
                  Text(
                    message.senderName,
                    style: TextStyle(
                      fontSize: 12,
                      color: isCurrentUser ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                Text(
                  message.content,
                  style: TextStyle(
                    color: isCurrentUser ? Colors.white : AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type your message...',
                border: InputBorder.none,
              ),
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    Icons.send,
                    color: AppColors.primary,
                  ),
            onPressed: _isLoading ? null : _sendMessage,
          ),
        ],
      ),
    );
  }

  void _showParticipants(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Consumer<CollaborativeProvider>(
        builder: (context, provider, child) {
          final session = provider.currentSession;
          if (session == null) return const SizedBox();

          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Participants (${session.participants.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...session.participants.map((participant) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withAlpha(30),
                        child: Text(
                          participant[0].toUpperCase(),
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(participant),
                      trailing: participant == session.creatorName
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(30),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Host',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : null,
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
} 