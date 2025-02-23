import 'package:flutter/material.dart';
import 'package:mp3_player/favorites.dart';
import 'package:mp3_player/songs.dart';

Container NavBar(BuildContext context) {
  return Container(
    height: 60,
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SongsScreen()),
            );
          },
          child: _buildNavItem(Icons.music_note, 'Music'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FavoritesPage(
                        favoriteSongs: [],
                      )),
            );
          },
          child: _buildNavItem(Icons.favorite_border, 'Favorite'),
        ),
        _buildNavItem(Icons.playlist_play, 'Playlist'),
      ],
    ),
  );
}

Widget _buildNavItem(IconData icon, String label) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: Colors.grey),
      const SizedBox(height: 4),
      Text(
        label,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
    ],
  );
}

BottomNavigationBar MyNavigationBar(BuildContext context) {
  return BottomNavigationBar(
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.library_music),
        label: 'Mi lista de música',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.favorite_border),
        label: 'Favoritos',
      ),
    ],
    onTap: (index) {
      switch (index) {
        case 0:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SongsScreen()),
          );
          break;
        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FavoritesPage(
                      favoriteSongs: [],
                    )),
          );
          break;
      }
    },
  );
}
