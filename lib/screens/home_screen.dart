import 'package:flutter/material.dart';
import 'package:music/providers/song_provider.dart';
import 'package:music/providers/theme_provider.dart';
import 'package:music/screens/favorites_screen.dart';
import 'package:music/widgets/shimmer_loading.dart';
import 'package:music/widgets/song_list_item.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SongProvider>(context, listen: false).loadInitialSongs();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      Provider.of<SongProvider>(context, listen: false).loadMoreSongs();
    }
  }

  void _onSearchSubmitted(String value) {
    if (value.trim().isNotEmpty) {
      Provider.of<SongProvider>(
        context,
        listen: false,
      ).searchSongs(value.trim());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music App'),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () => themeProvider.toggleTheme(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search songs...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          Provider.of<SongProvider>(
                            context,
                            listen: false,
                          ).searchSongs('pop');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onSubmitted: _onSearchSubmitted,
              onChanged: (value) => setState(() {}),
            ),
          ),
          Expanded(
            child: Consumer<SongProvider>(
              builder: (context, songProvider, child) {
                if (songProvider.isLoading) {
                  return const ShimmerLoading();
                }

                if (songProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading songs',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => songProvider.loadInitialSongs(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (songProvider.songs.isEmpty) {
                  return const Center(child: Text('No songs found'));
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount:
                      songProvider.songs.length +
                      (songProvider.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == songProvider.songs.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return SongListItem(
                      song: songProvider.songs[index],
                      allSongs: songProvider.songs,
                      index: index,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
