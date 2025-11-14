import 'package:flutter/material.dart';
import 'package:music/models/song_model.dart';
import 'package:music/providers/favorites_provider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audioplayers/audioplayers.dart';

class SongDetailScreen extends StatefulWidget {
  final Song song;
  final List<Song>? allSongs;
  final int? currentIndex;

  const SongDetailScreen({
    super.key,
    required this.song,
    this.allSongs,
    this.currentIndex,
  });

  @override
  State<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen> {
  late PageController _pageController;
  late int _currentIndex;
  final Map<int, AudioPlayer> _audioPlayers = {};
  final Map<int, bool> _playingStates = {};
  final Map<int, Duration> _durations = {};
  final Map<int, Duration> _positions = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex ?? 0;
    _pageController = PageController(initialPage: _currentIndex);
    _setupAudioPlayer(_currentIndex);
  }

  void _setupAudioPlayer(int index) {
    if (_audioPlayers.containsKey(index)) return;

    final player = AudioPlayer();
    _audioPlayers[index] = player;
    _playingStates[index] = false;
    _durations[index] = Duration.zero;
    _positions[index] = Duration.zero;

    player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _playingStates[index] = state == PlayerState.playing;
        });
      }
    });

    player.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _durations[index] = duration;
        });
      }
    });

    player.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _positions[index] = position;
        });
      }
    });
  }

  Future<void> _playPause(int index, String? previewUrl) async {
    if (previewUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preview not available')),
      );
      return;
    }

    final player = _audioPlayers[index];
    if (player == null) return;

    if (_playingStates[index] == true) {
      await player.pause();
    } else {
      // Pause all other players
      for (var entry in _audioPlayers.entries) {
        if (entry.key != index && _playingStates[entry.key] == true) {
          await entry.value.pause();
        }
      }
      await player.play(UrlSource(previewUrl));
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    for (var player in _audioPlayers.values) {
      player.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final songs = widget.allSongs ?? [widget.song];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Now Playing'),
        actions: [
          if (songs.length > 1)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Center(
                child: Text(
                  '${_currentIndex + 1}/${songs.length}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: songs.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
          _setupAudioPlayer(index);
          // Pause previous song
          for (var entry in _audioPlayers.entries) {
            if (entry.key != index && _playingStates[entry.key] == true) {
              entry.value.pause();
            }
          }
        },
        itemBuilder: (context, index) {
          return _buildSongPage(songs[index], index);
        },
      ),
    );
  }

  Widget _buildSongPage(Song song, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPlaying = _playingStates[index] ?? false;
    final duration = _durations[index] ?? Duration.zero;
    final position = _positions[index] ?? Duration.zero;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // Album Artwork with Shadow
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Hero(
              tag: 'song_${song.trackId}',
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: CachedNetworkImage(
                      imageUrl: song.artworkUrl100.replaceAll('100x100', '600x600'),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.music_note, size: 100),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Song Info Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                // Title and Artist
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.trackName,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            song.artistName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Consumer<FavoritesProvider>(
                      builder: (context, favProvider, child) {
                        final isFav = favProvider.isFavorite(song.trackId);
                        return Container(
                          decoration: BoxDecoration(
                            color: isFav
                                ? Theme.of(context).primaryColor.withOpacity(0.1)
                                : (isDark ? Colors.grey[800] : Colors.grey[200]),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Theme.of(context).primaryColor : null,
                              size: 28,
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
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Song Details Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.album_outlined,
                        label: 'Album',
                        value: song.collectionName,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.music_note_outlined,
                        label: 'Genre',
                        value: song.primaryGenreName,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.access_time_outlined,
                        label: 'Duration',
                        value: song.duration,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.attach_money_outlined,
                        label: 'Price',
                        value: '\$${song.trackPrice.toStringAsFixed(2)}',
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Audio Player Controls
                if (song.previewUrl != null)
                  Card(
                    elevation: isDark ? 8 : 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          // Progress Bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(position),
                                style: TextStyle(
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _formatDuration(duration),
                                style: TextStyle(
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 14,
                              ),
                            ),
                            child: Slider(
                              value: position.inSeconds.toDouble(),
                              max: duration.inSeconds.toDouble().clamp(1, double.infinity),
                              onChanged: (value) async {
                                await _audioPlayers[index]?.seek(
                                  Duration(seconds: value.toInt()),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Playback Controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildControlButton(
                                icon: Icons.replay_10,
                                onPressed: () async {
                                  final newPosition = position - const Duration(seconds: 10);
                                  await _audioPlayers[index]?.seek(
                                    newPosition < Duration.zero ? Duration.zero : newPosition,
                                  );
                                },
                                size: 40,
                                isDark: isDark,
                              ),
                              
                              // Play/Pause Button
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context).primaryColor,
                                      Theme.of(context).primaryColor.withOpacity(0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).primaryColor.withOpacity(0.4),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  ),
                                  iconSize: 40,
                                  color: Colors.white,
                                  onPressed: () => _playPause(index, song.previewUrl),
                                ),
                              ),
                              
                              _buildControlButton(
                                icon: Icons.forward_10,
                                onPressed: () async {
                                  final newPosition = position + const Duration(seconds: 10);
                                  await _audioPlayers[index]?.seek(
                                    newPosition > duration ? duration : newPosition,
                                  );
                                },
                                size: 40,
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Card(
                    elevation: isDark ? 8 : 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.music_off,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Preview not available',
                            style: TextStyle(
                              color: isDark ? Colors.grey[600] : Colors.grey[400],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Card(
      elevation: isDark ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required double size,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon),
        iconSize: size,
        color: isDark ? Colors.white : Colors.black87,
        onPressed: onPressed,
      ),
    );
  }
}