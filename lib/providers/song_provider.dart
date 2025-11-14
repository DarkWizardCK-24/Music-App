import 'package:flutter/material.dart';
import 'package:music/models/song_model.dart';
import 'package:music/services/api_service.dart';

class SongProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Song> _songs = [];
  List<Song> get songs => _songs;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  String? _error;
  String? get error => _error;

  String _searchTerm = 'pop';
  int _currentOffset = 0;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  Future<void> searchSongs(String term) async {
    if (term.isEmpty) return;
    
    _searchTerm = term;
    _currentOffset = 0;
    _hasMore = true;
    _songs = [];
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newSongs = await _apiService.searchSongs(
        term: term,
        limit: 20,
        offset: 0,
      );
      _songs = newSongs;
      _hasMore = newSongs.length == 20;
      _currentOffset = 20;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadInitialSongs() async {
    if (_songs.isNotEmpty) return;
    await searchSongs('pop');
  }

  Future<void> loadMoreSongs() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final newSongs = await _apiService.searchSongs(
        term: _searchTerm,
        limit: 20,
        offset: _currentOffset,
      );
      
      if (newSongs.isEmpty) {
        _hasMore = false;
      } else {
        _songs.addAll(newSongs);
        _currentOffset += newSongs.length;
        _hasMore = newSongs.length == 20;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}