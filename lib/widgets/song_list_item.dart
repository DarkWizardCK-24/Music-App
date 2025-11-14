import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:music/models/song_model.dart';
import 'package:music/providers/favorites_provider.dart';
import 'package:music/providers/song_provider.dart';
import 'package:music/screens/song_detail_screen.dart';
import 'package:provider/provider.dart';

class SongListItem extends StatelessWidget {
  final Song song;
  final List<Song>? allSongs;
  final int? index;

  const SongListItem({
    super.key,
    required this.song,
    this.allSongs,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: Hero(
          tag: 'song_${song.trackId}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: song.artworkUrl100,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 60,
                height: 60,
                color: Colors.grey[300],
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 60,
                height: 60,
                color: Colors.grey[300],
                child: const Icon(Icons.music_note),
              ),
            ),
          ),
        ),
        title: Text(
          song.trackName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              song.artistName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  song.duration,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.label,
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    song.primaryGenreName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Consumer<FavoritesProvider>(
          builder: (context, favProvider, child) {
            final isFav = favProvider.isFavorite(song.trackId);
            return IconButton(
              icon: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? Colors.red : null,
              ),
              onPressed: () {
                favProvider.toggleFavorite(song);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isFav ? 'Removed from favorites' : 'Added to favorites',
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            );
          },
        ),
        onTap: () {
          // Get all songs from the provider if not provided
          final songs = allSongs ?? Provider.of<SongProvider>(context, listen: false).songs;
          final currentIndex = index ?? songs.indexWhere((s) => s.trackId == song.trackId);
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SongDetailScreen(
                song: song,
                allSongs: songs,
                currentIndex: currentIndex >= 0 ? currentIndex : 0,
              ),
            ),
          );
        },
      ),
    );
  }
}