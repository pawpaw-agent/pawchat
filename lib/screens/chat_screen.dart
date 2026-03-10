import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/chat_service.dart';
import '../services/websocket_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import '../widgets/connection_status.dart';
import 'sessions_screen.dart';
import 'settings_screen.dart';

/// ChatScreen - Frontend UI component
/// Main chat interface for messaging with OpenClaw agents
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _chatService = ChatService();
  final _wsService = WebSocketService();
  final _scrollController = ScrollController();
  
  List<Message> _messages = [];
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _chatService.init();
    _loadMessages();
    _listenToConnection();
  }

  void _loadMessages() {
    setState(() {
      _messages = _chatService.currentMessages;
    });
  }

  void _listenToConnection() {
    // Listen to connection state changes
    _wsService.connectionStream.listen((state) {
      if (mounted) {
        setState(() {
          _isConnected = state == ConnectionState.connected;
        });
      }
    });

    // Listen to new messages
    _chatService.messagesStream.listen((messages) {
      if (mounted) {
        setState(() {
          _messages = messages;
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    
    try {
      await _chatService.sendMessage(content);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PawChat',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _isConnected ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _isConnected ? 'Connected' : 'Disconnected',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isConnected ? Colors.green.shade300 : Colors.red.shade300,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Sessions Button
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SessionsScreen()),
              );
            },
            tooltip: 'Sessions',
          ),
          // Settings Button
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            tooltip: 'Settings',
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          // Connection Status Bar
          const ConnectionStatus(),
          
          // Message List
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : _buildMessageList(),
          ),
          
          // Message Input
          MessageInput(onSend: _sendMessage),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation with OpenClaw',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final showAvatar = index == 0 || 
            _messages[index - 1].role != message.role;
        
        return MessageBubble(
          message: message,
          showAvatar: showAvatar,
        );
      },
    );
  }

  @override
  void dispose() {
    _chatService.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
