import 'package:flutter/material.dart';
import 'package:music/providers/favorites_provider.dart';
import 'package:music/widgets/song_list_item.dart';
import 'package:provider/provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: Consumer<FavoritesProvider>(
        builder: (context, favProvider, child) {
          if (favProvider.favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add some songs to your favorites!',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: favProvider.favorites.length,
            itemBuilder: (context, index) {
              final song = favProvider.favorites[index];
              return Dismissible(
                key: Key(song.trackId.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                onDismissed: (direction) {
                  favProvider.removeFavorite(song.trackId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${song.trackName} removed from favorites'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () {
                          favProvider.toggleFavorite(song);
                        },
                      ),
                    ),
                  );
                },
                child: SongListItem(
                  song: song,
                  allSongs: favProvider.favorites,
                  index: index,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
