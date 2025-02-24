import 'package:flutter/material.dart';
import 'favorites_manager.dart';
import 'player.dart';

class FavoritesView extends StatefulWidget {
  const FavoritesView({Key? key}) : super(key: key);

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  List<String> favoriteSongs = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final songs = await FavoritesManager.getFavorites();
    setState(() {
      favoriteSongs = songs;
    });
  }

  void _removeFavorite(String songPath) async {
    await FavoritesManager.removeFavorite(songPath);
    _loadFavorites(); // Refresca la lista
  }

  void _playFromFavorites(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MusicPlayerView(
          fileNames: favoriteSongs,
          currentSong: index,
          onFavoriteChanged: (String path) {
            _loadFavorites(); // Refresca la lista si cambia el estado
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: favoriteSongs.isEmpty
          ? const Center(child: Text('No hay canciones favoritas'))
          : ListView.builder(
              itemCount: favoriteSongs.length,
              itemBuilder: (context, index) {
                final songPath = favoriteSongs[index];
                final songName = songPath.split('/').last;

                return ListTile(
                  title: Text(songName, overflow: TextOverflow.ellipsis),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeFavorite(songPath),
                  ),
                  onTap: () => _playFromFavorites(index), // Reproduce la canción seleccionada
                );
              },
            ),
    );
  }
}