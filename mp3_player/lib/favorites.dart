import 'package:flutter/material.dart';
import 'favorites_manager.dart';
import 'player.dart';

class FavoriteSongsScreen extends StatefulWidget {
  @override
  _FavoriteSongsScreenState createState() => _FavoriteSongsScreenState();
}

class _FavoriteSongsScreenState extends State<FavoriteSongsScreen> {
  List<String> _favoriteSongs = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await FavoritesManager.getFavorites();
    setState(() {
      _favoriteSongs = favorites;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Canciones Favoritas")),
      body: ListView.builder(
        itemCount: _favoriteSongs.length,
        itemBuilder: (context, index) {
          final song = _favoriteSongs[index];
          return ListTile(
            title: Text(song.split('/').last),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await FavoritesManager.removeFavorite(song);
                _loadFavorites();
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MusicPlayerView(
                    fileNames: _favoriteSongs,
                    currentSong: index,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
