import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

import 'screens/film_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialise media_kit for the host platform (Windows, Android, etc.)
  MediaKit.ensureInitialized();

  runApp(const LitePlayerApp());
}

class LitePlayerApp extends StatelessWidget {
  const LitePlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LitePlayer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Colors.blueAccent,
          surface: Color(0xFF1E1E1E),
        ),
      ),
      home: const FilmListScreen(),
    );
  }
}
