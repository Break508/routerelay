import 'package:flutter/material.dart';
import 'ui/map_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RouteRelayApp());
}

class RouteRelayApp extends StatelessWidget {
  const RouteRelayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RouteRelay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MapScreen(),
    );
  }
}
