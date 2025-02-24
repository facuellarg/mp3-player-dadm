import 'package:shared_preferences/shared_preferences.dart';

class FavoritesManager {
  static Future<List<String>> getFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('favoriteSongs') ?? [];
  }

  static Future<void> addFavorite(String songPath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favorites = await getFavorites();
    if (!favorites.contains(songPath)) {
      favorites.add(songPath);
    }
    await prefs.setStringList('favoriteSongs', favorites);
  }

  static Future<void> removeFavorite(String songPath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favorites = await getFavorites();
    favorites.remove(songPath);
    await prefs.setStringList('favoriteSongs', favorites);
  }

  static Future<bool> isFavorite(String songPath) async {
    List<String> favorites = await getFavorites();
    return favorites.contains(songPath);
  }
}
