import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:music/models/song_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider with ChangeNotifier {
  List<Song> _favorites = [];
  List<Song> get favorites => _favorites;

  static const String _storageKey = 'favorite_songs';

  FavoritesProvider() {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        _favorites = jsonList.map((json) => Song.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _favorites.map((song) => song.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  bool isFavorite(int trackId) {
    return _favorites.any((song) => song.trackId == trackId);
  }

  Future<void> toggleFavorite(Song song) async {
    if (isFavorite(song.trackId)) {
      _favorites.removeWhere((s) => s.trackId == song.trackId);
    } else {
      _favorites.add(song);
    }
    await _saveFavorites();
    notifyListeners();
  }

  Future<void> removeFavorite(int trackId) async {
    _favorites.removeWhere((song) => song.trackId == trackId);
    await _saveFavorites();
    notifyListeners();
  }
}