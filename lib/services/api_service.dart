import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:music/models/song_model.dart';

class ApiService {
  final String baseUrl = dotenv.env['API_URL'] ?? "";

  Future<List<Song>> searchSongs({
    required String term,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl?term=$term&entity=song&limit=$limit&offset=$offset');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        return results.map((json) => Song.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load songs');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Song>> getPopularSongs({int limit = 20, int offset = 0}) async {
    return searchSongs(term: 'pop', limit: limit, offset: offset);
  }
}