import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  final List<Map<String, String>> favoriteSongs;

  FavoritesPage({required this.favoriteSongs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
      ),
      body: favoriteSongs.isEmpty
          ? Center(child: Text('No favorites yet!'))
          : ListView.builder(
              itemCount: favoriteSongs.length,
              itemBuilder: (context, index) {
                final song = favoriteSongs[index];
                return ListTile(
                  leading: Icon(Icons.music_note, color: Colors.orange),
                  title: Text(song['title']!),
                  subtitle: Text(song['artist']!),
                  trailing: Icon(Icons.favorite, color: Colors.red),
                );
              },
            ),
    );
  }
}
