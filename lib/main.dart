import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'services/websocket_service.dart';
import 'services/chat_service.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage service
  final storage = StorageService();
  await storage.init();
  
  runApp(const PawChatApp());
}

class PawChatApp extends StatelessWidget {
  const PawChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<StorageService>.value(value: StorageService()),
        Provider<WebSocketService>.value(value: WebSocketService()),
        Provider<ChatService>.value(value: ChatService()),
        Provider<AuthService>.value(value: AuthService()),
      ],
      child: MaterialApp(
        title: 'PawChat',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
