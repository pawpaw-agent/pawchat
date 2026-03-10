import 'package:flutter/material.dart';
import '../models/gateway_config.dart';
import '../services/storage_service.dart';
import '../services/websocket_service.dart' as ws;
import 'chat_screen.dart';

/// ConnectionScreen - Frontend UI component
/// Allows users to configure and connect to OpenClaw Gateway
class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController(text: '192.168.1.100');
  final _portController = TextEditingController(text: '8080');
  final _nameController = TextEditingController(text: 'My OpenClaw Gateway');
  
  bool _useTLS = false;
  bool _isConnecting = false;
  String? _errorMessage;

  final _storage = StorageService();
  final _wsService = WebSocketService();

  @override
  void initState() {
    super.initState();
    _loadSavedConfig();
  }

  Future<void> _loadSavedConfig() async {
    final activeGateway = _storage.getActiveGateway();
    if (activeGateway != null) {
      setState(() {
        _hostController.text = activeGateway.host;
        _portController.text = activeGateway.port.toString();
        _nameController.text = activeGateway.name;
        _useTLS = activeGateway.useTLS;
      });
    }
  }

  Future<void> _connect() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isConnecting = true;
      _errorMessage = null;
    });

    try {
      final config = GatewayConfig(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        host: _hostController.text,
        port: int.parse(_portController.text),
        useTLS: _useTLS,
      );

      await _storage.saveGatewayConfig(config);
      await _storage.setActiveGateway(config.id);

      await _wsService.connect(config);

      // Wait for connection result
      await _wsService.connectionStream.firstWhere(
        (state) => state == ws.ConnectionState.connected || state == ws.ConnectionState.error,
      );

      if (mounted && _wsService.state == ws.ConnectionState.connected) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ChatScreen()),
        );
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Connection failed. Please check gateway settings.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Connection failed: ${e.toString()}';
        });
      }
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect to Gateway'),
        elevation: 0,
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // Header
              const Text(
                'Gateway Configuration',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your OpenClaw Gateway details',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),
              
              // Gateway Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Gateway Name',
                  prefixIcon: Icon(Icons.dns),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Host IP Field
              TextFormField(
                controller: _hostController,
                decoration: const InputDecoration(
                  labelText: 'Host IP',
                  prefixIcon: Icon(Icons.ip),
                  border: OutlineInputBorder(),
                  hintText: '192.168.1.100',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter host IP';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Port Field
              TextFormField(
                controller: _portController,
                decoration: const InputDecoration(
                  labelText: 'Port',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                  hintText: '8080',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter port';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // TLS Toggle
              SwitchListTile(
                title: const Text('Use TLS (WSS)'),
                subtitle: const Text('Enable secure connection'),
                value: _useTLS,
                onChanged: (value) {
                  setState(() {
                    _useTLS = value;
                  });
                },
              ),
              
              // Error Message
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const Spacer(),
              
              // Connect Button
              ElevatedButton(
                onPressed: _isConnecting ? null : _connect,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isConnecting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Connect',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
              ),
              const SizedBox(height: 16),
              
              // Help Button
              TextButton(
                onPressed: _showHelpDialog,
                child: const Text('How to find Gateway IP?'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Finding Gateway IP'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. On your computer running OpenClaw:'),
            SizedBox(height: 8),
            Text('   Run: openclaw gateway status'),
            SizedBox(height: 12),
            Text('2. Look for the gateway address'),
            SizedBox(height: 12),
            Text('3. Ensure both devices are on the same network'),
            SizedBox(height: 12),
            Text('4. Default port is 8080'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
