import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/message.dart';

/// MessageBubble - Frontend UI widget
/// Displays individual chat messages with styling based on role
class MessageBubble extends StatelessWidget {
  final Message message;
  final bool showAvatar;

  const MessageBubble({
    super.key,
    required this.message,
    this.showAvatar = false,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final isSystem = message.role == MessageRole.system;
    final timeFormat = DateFormat('HH:mm');

    // System messages have different styling
    if (isSystem) {
      return _buildSystemMessage();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Agent Avatar (left side)
          if (!isUser && showAvatar) ...[
            CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Icon(Icons.smart_toy, color: Colors.blue.shade700, size: 20),
              radius: 16,
            ),
            const SizedBox(width: 8),
          ] else if (!isUser) ...[
            const SizedBox(width: 40),
          ],
          
          // Message Bubble
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.blue.shade600 : Colors.grey.shade200,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Message Content
                      Text(
                        message.content,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black87,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      // Timestamp and Status
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            timeFormat.format(message.timestamp),
                            style: TextStyle(
                              fontSize: 11,
                              color: isUser ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          if (isUser) ...[
                            const SizedBox(width: 4),
                            _buildStatusIcon(),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // User Avatar (right side)
          if (isUser && showAvatar) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: Icon(Icons.person, color: Colors.green.shade700, size: 20),
              radius: 16,
            ),
          ] else if (isUser) ...[
            const SizedBox(width: 40),
          ],
        ],
      ),
    );
  }

  Widget _buildSystemMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            message.content,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (message.status) {
      case MessageStatus.sending:
        return const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
          ),
        );
      case MessageStatus.sent:
        return const Icon(Icons.check, size: 14, color: Colors.white70);
      case MessageStatus.delivered:
        return const Icon(Icons.done_all, size: 14, color: Colors.white70);
      case MessageStatus.failed:
        return const Icon(Icons.error_outline, size: 14, color: Colors.red);
    }
  }
}
