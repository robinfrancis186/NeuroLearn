import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/collaborative_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/optimized_image.dart';

class CollaborativeSessionScreen extends StatefulWidget {
  final String sessionId;

  const CollaborativeSessionScreen({
    Key? key,
    required this.sessionId,
  }) : super(key: key);

  @override
  State<CollaborativeSessionScreen> createState() => _CollaborativeSessionScreenState();
}

class _CollaborativeSessionScreenState extends State<CollaborativeSessionScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  bool _isSending = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _joinSession();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _leaveSession();
    super.dispose();
  }

  Future<void> _joinSession() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final collaborativeProvider = Provider.of<CollaborativeProvider>(context, listen: false);
      final success = await collaborativeProvider.joinSession(widget.sessionId);
      
      if (!success && mounted) {
        setState(() {
          _errorMessage = 'Failed to join session. The session may not exist or you may not have permission to join.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error joining session: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _leaveSession() async {
    try {
      final collaborativeProvider = Provider.of<CollaborativeProvider>(context, listen: false);
      await collaborativeProvider.leaveSession();
    } catch (e) {
      debugPrint('Error leaving session: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final collaborativeProvider = Provider.of<CollaborativeProvider>(context, listen: false);
      await collaborativeProvider.sendMessage(_messageController.text);
      _messageController.clear();
      
      // Scroll to bottom after sending message
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _sendProblem() async {
    final collaborativeProvider = Provider.of<CollaborativeProvider>(context, listen: false);
    final session = collaborativeProvider.currentSession;
    
    if (session == null) {
      return;
    }
    
    // Show dialog to create a problem
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) {
          String problem = '';
          
          return AlertDialog(
            title: const Text('Share a Problem'),
            content: TextField(
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Describe the problem you want to share...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                problem = value;
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (problem.isNotEmpty) {
                    Navigator.pop(context);
                    await collaborativeProvider.sendProblem(problem, session.subject);
                  }
                },
                child: const Text('Share'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _sendSolution(String problemId) async {
    final collaborativeProvider = Provider.of<CollaborativeProvider>(context, listen: false);
    
    // Show dialog to create a solution
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) {
          String solution = '';
          
          return AlertDialog(
            title: const Text('Share a Solution'),
            content: TextField(
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Describe your solution...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                solution = value;
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (solution.isNotEmpty) {
                    Navigator.pop(context);
                    await collaborativeProvider.sendSolution(solution, problemId);
                  }
                },
                child: const Text('Share'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<CollaborativeProvider>(
          builder: (context, provider, child) {
            final session = provider.currentSession;
            return Text(
              session?.name ?? 'Collaborative Session',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: _showParticipants,
            tooltip: 'Participants',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareSessionCode,
            tooltip: 'Share Session Code',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.withAlpha(150),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.withAlpha(200),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    _buildSessionInfo(),
                    Expanded(
                      child: _buildMessageList(),
                    ),
                    _buildMessageInput(),
                  ],
                ),
    );
  }

  Widget _buildSessionInfo() {
    return Consumer<CollaborativeProvider>(
      builder: (context, provider, child) {
        final session = provider.currentSession;
        if (session == null) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getSubjectColor(session.subject).withAlpha(30),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _getSubjectIcon(session.subject),
                  color: _getSubjectColor(session.subject),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.subject,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${session.participants.length} participants',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _sendProblem,
                icon: const Icon(Icons.add_circle_outline, size: 16),
                label: const Text('Share Problem'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getSubjectColor(session.subject),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageList() {
    return Consumer<CollaborativeProvider>(
      builder: (context, provider, child) {
        final session = provider.currentSession;
        if (session == null) {
          return const Center(
            child: Text('No session data available'),
          );
        }

        if (session.messages.isEmpty) {
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
                  'Start the conversation by sending a message',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: session.messages.length,
          itemBuilder: (context, index) {
            final message = session.messages[index];
            final isCurrentUser = message.senderId == provider.currentUser?.id;
            
            if (message.type == MessageType.system) {
              return _buildSystemMessage(message);
            } else if (message.type == MessageType.problem) {
              return _buildProblemMessage(message, isCurrentUser);
            } else if (message.type == MessageType.solution) {
              return _buildSolutionMessage(message, isCurrentUser);
            } else {
              return _buildTextMessage(message, isCurrentUser);
            }
          },
        );
      },
    );
  }

  Widget _buildSystemMessage(CollaborativeMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              message.content,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  Widget _buildTextMessage(CollaborativeMessage message, bool isCurrentUser) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isCurrentUser ? AppColors.primary : AppColors.lightBg,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isCurrentUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  message.senderName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isCurrentUser ? Colors.white.withAlpha(200) : AppColors.primary,
                  ),
                ),
              ),
            Text(
              message.content,
              style: TextStyle(
                color: isCurrentUser ? Colors.white : AppColors.textPrimary,
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: isCurrentUser ? Colors.white.withAlpha(180) : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProblemMessage(CollaborativeMessage message, bool isCurrentUser) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getSubjectColor(message.metadata?['subject'] ?? 'Math').withAlpha(100),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getSubjectColor(message.metadata?['subject'] ?? 'Math').withAlpha(30),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.help_outline,
                  size: 16,
                  color: _getSubjectColor(message.metadata?['subject'] ?? 'Math'),
                ),
                const SizedBox(width: 8),
                Text(
                  'Problem shared by ${message.senderName}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getSubjectColor(message.metadata?['subject'] ?? 'Math'),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              message.content,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _sendSolution(message.id),
                  icon: const Icon(Icons.lightbulb_outline, size: 16),
                  label: const Text('Share Solution'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _getSubjectColor(message.metadata?['subject'] ?? 'Math'),
                    side: BorderSide(
                      color: _getSubjectColor(message.metadata?['subject'] ?? 'Math').withAlpha(100),
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

  Widget _buildSolutionMessage(CollaborativeMessage message, bool isCurrentUser) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withAlpha(100),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(30),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  size: 16,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  'Solution shared by ${message.senderName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              message.content,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () {
              // TODO: Implement file attachment
            },
            color: AppColors.primary,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
              ),
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: _isSending
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : const Icon(Icons.send),
            onPressed: _isSending ? null : _sendMessage,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  void _showParticipants() {
    final collaborativeProvider = Provider.of<CollaborativeProvider>(context, listen: false);
    final session = collaborativeProvider.currentSession;
    
    if (session == null) {
      return;
    }
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text(
                    'Participants',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${session.participants.length} total',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: session.participants.length,
                  itemBuilder: (context, index) {
                    final participant = session.participants[index];
                    final isCreator = participant.id == session.creatorId;
                    
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withAlpha(30),
                        child: Text(
                          participant.name.isNotEmpty
                              ? participant.name[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(participant.name),
                          const SizedBox(width: 8),
                          if (isCreator)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(30),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Creator',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Text(
                        participant.isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          color: participant.isOnline ? Colors.green : Colors.grey,
                        ),
                      ),
                      trailing: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: participant.isOnline ? Colors.green : Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _shareSessionCode() {
    final collaborativeProvider = Provider.of<CollaborativeProvider>(context, listen: false);
    final session = collaborativeProvider.currentSession;
    
    if (session == null) {
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Share Session Code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Share this code with others to join this session:',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      session.id,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        // TODO: Implement copy to clipboard
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Session code copied to clipboard')),
                        );
                      },
                      tooltip: 'Copy to clipboard',
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Color _getSubjectColor(String subject) {
    switch (subject) {
      case 'Math':
        return Colors.blue;
      case 'Language':
        return Colors.green;
      case 'Memory':
        return Colors.purple;
      case 'Life Skills':
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject) {
      case 'Math':
        return Icons.calculate;
      case 'Language':
        return Icons.language;
      case 'Memory':
        return Icons.psychology;
      case 'Life Skills':
        return Icons.accessibility_new;
      default:
        return Icons.school;
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
} 