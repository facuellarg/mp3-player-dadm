import 'package:flutter/material.dart';
import 'favorites_manager.dart';
import 'player.dart';
import 'dart:io';

class FavoriteSongsScreen extends StatefulWidget {
  @override
  _FavoriteSongsScreenState createState() => _FavoriteSongsScreenState();
}

class _FavoriteSongsScreenState extends State<FavoriteSongsScreen> {
  ValueNotifier<List<String>> _favoriteSongs = ValueNotifier<List<String>>([]);

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await FavoritesManager.getFavorites();
    _favoriteSongs.value = favorites;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Canciones Favoritas"),
        backgroundColor: Colors.teal,
      ),
      body: ValueListenableBuilder<List<String>>(
        valueListenable: _favoriteSongs,
        builder: (context, favoriteSongs, _) {
          if (favoriteSongs.isEmpty) {
            return const Center(child: Text("No hay canciones favoritas"));
          }

          return ListView.builder(
            itemCount: favoriteSongs.length,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            itemBuilder: (context, index) {
              final song = favoriteSongs[index];
              final songName = song.split('/').last;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: const Icon(Icons.music_note, color: Colors.teal),
                  title: Text(
                    songName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () async {
                      await FavoritesManager.removeFavorite(song);
                      _loadFavorites();
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
