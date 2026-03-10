import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/session.dart';
import '../services/chat_service.dart';

/// SessionsScreen - Frontend UI component
/// Displays list of chat sessions with management options
class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  final _chatService = ChatService();
  List<Session> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
    });

    final sessions = await _chatService.getSessions();
    
    setState(() {
      _sessions = sessions;
      _isLoading = false;
    });
  }

  Future<void> _createNewSession() async {
    await _chatService.createSession();
    _loadSessions();
  }

  Future<void> _deleteSession(Session session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Session'),
        content: Text('Are you sure you want to delete "${session.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _chatService.deleteSession(session.id);
      _loadSessions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sessions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewSession,
            tooltip: 'New Session',
          ),
        ],
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
              ? _buildEmptyState()
              : _buildSessionList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'No sessions yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to create a new session',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _createNewSession,
            icon: const Icon(Icons.add),
            label: const Text('New Session'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionList() {
    return ListView.builder(
      itemCount: _sessions.length,
      itemBuilder: (context, index) {
        final session = _sessions[index];
        final dateFormat = DateFormat('MMM d, yyyy HH:mm');

        return Dismissible(
          key: Key(session.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => _deleteSession(session),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: session.isActive 
                  ? Colors.blue.shade100 
                  : Colors.grey.shade100,
              child: Icon(
                Icons.chat_bubble,
                color: session.isActive ? Colors.blue : Colors.grey,
                size: 20,
              ),
            ),
            title: Text(
              session.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              session.lastMessage ?? 'No messages',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            trailing: Text(
              dateFormat.format(session.updatedAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            onTap: () {
              _chatService.selectSession(session.id);
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }
}
