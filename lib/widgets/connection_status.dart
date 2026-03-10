import 'package:flutter/material.dart';
import '../services/websocket_service.dart';

/// ConnectionStatus - Frontend UI widget
/// Displays current WebSocket connection status with visual indicator
class ConnectionStatus extends StatelessWidget {
  const ConnectionStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<WsConnectionState>(
      stream: WebSocketService().connectionStream,
      initialData: WebSocketService().state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? WsConnectionState.disconnected;
        
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
              if (state == WsConnectionState.error)
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

  Color _getColor(WsConnectionState state) {
    switch (state) {
      case WsConnectionState.connected:
        return Colors.green.shade600;
      case WsConnectionState.connecting:
        return Colors.orange.shade600;
      case WsConnectionState.error:
        return Colors.red.shade600;
      case WsConnectionState.disconnected:
        return Colors.grey.shade600;
    }
  }

  Widget _buildStatusIndicator(WsConnectionState state) {
    switch (state) {
      case WsConnectionState.connected:
        return const CircleAvatar(
          radius: 6,
          backgroundColor: Colors.white,
        );
      case WsConnectionState.connecting:
        return SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      case WsConnectionState.error:
        return const CircleAvatar(
          radius: 6,
          backgroundColor: Colors.white,
          child: Icon(Icons.close, size: 10, color: Colors.red),
        );
      case WsConnectionState.disconnected:
        return CircleAvatar(
          radius: 6,
          backgroundColor: Colors.white.withOpacity(0.5),
        );
    }
  }

  String _getStatusText(WsConnectionState state) {
    switch (state) {
      case WsConnectionState.connected:
        return 'Connected to Gateway';
      case WsConnectionState.connecting:
        return 'Connecting...';
      case WsConnectionState.error:
        return 'Connection failed - Tap to retry';
      case WsConnectionState.disconnected:
        return 'Disconnected';
    }
  }
}
