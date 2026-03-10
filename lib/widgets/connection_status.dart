import 'package:flutter/material.dart';
import '../services/websocket_service.dart';

/// ConnectionStatus - Frontend UI widget
/// Displays current WebSocket connection status with visual indicator
class ConnectionStatus extends StatelessWidget {
  const ConnectionStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectionState>(
      stream: WebSocketService().connectionStream,
      initialData: WebSocketService().state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? ConnectionState.disconnected;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: _getColor(state),
          child: Row(
            children: [
              // Status Indicator
              _buildStatusIndicator(state),
              const SizedBox(width: 8),
              
              // Status Text
              Expanded(
                child: Text(
                  _getStatusText(state),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Retry Button (shown on error)
              if (state == ConnectionState.error)
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
                  onPressed: () {
                    WebSocketService().disconnect();
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Retry',
                ),
            ],
          ),
        );
      },
    );
  }

  Color _getColor(ConnectionState state) {
    switch (state) {
      case ConnectionState.connected:
        return Colors.green.shade600;
      case ConnectionState.connecting:
        return Colors.orange.shade600;
      case ConnectionState.error:
        return Colors.red.shade600;
      case ConnectionState.disconnected:
        return Colors.grey.shade600;
    }
  }

  Widget _buildStatusIndicator(ConnectionState state) {
    switch (state) {
      case ConnectionState.connected:
        return const CircleAvatar(
          radius: 6,
          backgroundColor: Colors.white,
        );
      case ConnectionState.connecting:
        return SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      case ConnectionState.error:
        return const CircleAvatar(
          radius: 6,
          backgroundColor: Colors.white,
          child: Icon(Icons.close, size: 10, color: Colors.red),
        );
      case ConnectionState.disconnected:
        return CircleAvatar(
          radius: 6,
          backgroundColor: Colors.white.withOpacity(0.5),
        );
    }
  }

  String _getStatusText(ConnectionState state) {
    switch (state) {
      case ConnectionState.connected:
        return 'Connected to Gateway';
      case ConnectionState.connecting:
        return 'Connecting...';
      case ConnectionState.error:
        return 'Connection failed - Tap to retry';
      case ConnectionState.disconnected:
        return 'Disconnected';
    }
  }
}
