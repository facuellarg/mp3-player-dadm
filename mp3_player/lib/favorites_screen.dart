import 'package:flutter/material.dart';
import 'favorites_manager.dart';
import 'player.dart';
import 'favorites.dart';
import 'dart:io';

class FavoriteSongsScreen extends StatefulWidget {
  @override
  _FavoriteSongsScreenState createState() => _FavoriteSongsScreenState();
}

class _FavoriteSongsScreenState extends State<FavoriteSongsScreen> {
  // Usamos un ValueNotifier para escuchar los cambios de la lista de favoritos
  ValueNotifier<List<String>> _favoriteSongs = ValueNotifier<List<String>>([]);

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await FavoritesManager.getFavorites();
    _favoriteSongs.value = favorites; // Actualizamos el ValueNotifier
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Canciones Favoritas")),
      body: ValueListenableBuilder<List<String>>(
        valueListenable: _favoriteSongs,  // Escuchamos los cambios del ValueNotifier
        builder: (context, favoriteSongs, _) {
          return ListView.builder(
            itemCount: favoriteSongs.length,
            itemBuilder: (context, index) {
              final song = favoriteSongs[index];
              return ListTile(
                title: Text(song.split('/').last),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    // Eliminar la canción de favoritos
                    await FavoritesManager.removeFavorite(song);
                    _loadFavorites();  // Recargamos los favoritos
                  },
                ),
                onTap: () {
                  final songFile = File(favoriteSongs[index]);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MusicPlayerView(
                        fileNames: favoriteSongs,
                        currentSong: index,
                        onFavoriteChanged: (songPath) {
                          setState(() {
                            if (_favoriteSongs.value.contains(songPath)) {
                              _favoriteSongs.value.remove(songPath);
                            } else {
                              _favoriteSongs.value.add(songPath);
                            }
                          });
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
