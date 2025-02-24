import 'package:flutter/material.dart';
import 'songs.dart';
import "player.dart";
import 'package:mp3_player/favorites_screen.dart';
import 'package:mp3_player/favorites_manager.dart';
import './ai.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music',
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: HomeScreen(
        isDarkMode: isDarkMode,
        onThemeChanged: (bool value) {
          setState(() {
            isDarkMode = value;
          });
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Configuración') {
                _showThemeDialog(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'Configuración',
                child: Text('Configuración'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SongsScreen()),
              );
            },
            child: const Text('Ver la lista de todas las canciones'),
          ),
          ElevatedButton(
            onPressed: () {
              _showThemeDialog(context);
            },
            child: const Text('Configuración'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoriteSongsScreen()),
              );
            },
            child: const Text('Ver canciones favoritas'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SongDetailsScreen()),
              );
            },
            child: const Text('Artificial Intelligence'),
          ),
        ] 
      ),
      
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Configuración de Tema'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Modo Oscuro'),
              Switch(
                value: isDarkMode,
                onChanged: (bool value) {
                  onThemeChanged(value);
                  Navigator.of(context).pop(); // Cierra el diálogo
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
