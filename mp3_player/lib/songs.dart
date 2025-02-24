import 'package:flutter/material.dart';
import 'package:mp3_player/nav_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import "player.dart";

class SongsScreen extends StatefulWidget {
  const SongsScreen({super.key});

  @override
  State<SongsScreen> createState() => _SongsScreenState();
}

class _SongsScreenState extends State<SongsScreen> {
  List<FileSystemEntity> allFiles = [];
  List<String> fileNames = [];
  List<String> favoriteSongs = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFilesRecursively();
    _loadFavorites();
  }

  Future<void> _loadFilesRecursively() async {
    setState(() {
      isLoading = true;
    });
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
    if (await Permission.manageExternalStorage.request().isGranted) {
      final directory = Directory('/storage/emulated/0/Music');
      if (directory.existsSync()) {
        try {
          final List<FileSystemEntity> files = [];
          await for (var file
              in directory.list(recursive: true, followLinks: false)) {
            try {
              if (file is File && (file.path.endsWith('.mp3') || file.path.endsWith('.wav'))) {
                files.add(file);
                fileNames.add(file.resolveSymbolicLinksSync());
              }
            } catch (e) {
              print("Error al acceder a ${file.path}: $e");
            }
          }
          setState(() {
            allFiles = files;
          });
        } catch (e) {
          print("Error al listar archivos: $e");
        }
      } else {
        print("Directorio no encontrado");
      }
    } else {
      print("Permisos de almacenamiento denegados.");
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteSongs = prefs.getStringList('favoriteSongs') ?? [];
    });
  }

  Future<void> _toggleFavorite(String filePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (favoriteSongs.contains(filePath)) {
        favoriteSongs.remove(filePath);
      } else {
        favoriteSongs.add(filePath);
      }
    });
    await prefs.setStringList('favoriteSongs', favoriteSongs);
  }

  Future<void> _playFile(FileSystemEntity file) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reproduciendo: ${file.path.split("/").last}')),
    );

    // Esperar el resultado de MusicPlayerView
    final bool? favoriteChanged = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MusicPlayerView(
          fileNames: fileNames,
          currentSong: fileNames.indexOf(file.path),
        ),
      ),
    );

    // Si hubo cambios en favoritos, recargar la lista
    if (favoriteChanged == true) {
      _loadFavorites();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archivos encontrados'),
        leading: PopupMenuButton<String>(
          onSelected: (value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Seleccionaste: $value')),
            );
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(
              value: 'Configuración',
              child: Text('Configuración'),
            ),
            const PopupMenuItem(
              value: 'Acerca de',
              child: Text('Acerca de'),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : allFiles.isNotEmpty
              ? ListView.builder(
                  itemCount: allFiles.length,
                  itemBuilder: (context, index) {
                    final file = allFiles[index];
                    final isFavorite = favoriteSongs.contains(file.path);
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: const Icon(Icons.insert_drive_file),
                        title: Text(file.path.split("/").last),
                        subtitle: Text(file.path),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.play_arrow),
                              onPressed: () => _playFile(file),
                              tooltip: 'Reproducir',
                            ),
                            IconButton(
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : null,
                              ),
                              onPressed: () => _toggleFavorite(file.path),
                              tooltip: 'Agregar a favoritos',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : const Center(
                  child: Text('No se encontraron archivos.'),
                ),
      bottomNavigationBar: MyNavigationBar(context),
    );
  }
}
