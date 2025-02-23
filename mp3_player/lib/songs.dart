import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFilesRecursively();
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
              if (file is File && file.path.endsWith('.mp3') ||
                  file.path.endsWith('.wav')) {
                files.add(file);
                fileNames.add(file.resolveSymbolicLinksSync());
              }
            } catch (e) {
              // Ignora carpetas inaccesibles
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

  void _playFile(FileSystemEntity file) {
    // print("file-------------");
    // print(file.path.split('/').last);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reproduciendo: ${file.path.split('/').last}')),
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MusicPlayerView(
          file,
          fileNames: fileNames,
          currentSong: fileNames.indexOf(file.path),
        ),
      ),
    );
  }

  void _addToFavorites(FileSystemEntity file) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('${file.path.split('/').last} añadido a favoritos')),
    );
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
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: const Icon(Icons.insert_drive_file),
                        title: Text(file.path.split('/').last),
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
                              icon: const Icon(Icons.favorite_border),
                              onPressed: () => _addToFavorites(file),
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
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Mi lista de música',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'Otro',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Mi lista de música seleccionada')),
              );
              break;
            case 1:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Favoritos seleccionados')),
              );
              break;
            case 2:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Otro seleccionado')),
              );
              break;
          }
        },
      ),
    );
  }
}
