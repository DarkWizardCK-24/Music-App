class Song {
  final int trackId;
  final String trackName;
  final String artistName;
  final String collectionName;
  final String artworkUrl100;
  final String? previewUrl;
  final double trackPrice;
  final String releaseDate;
  final int trackTimeMillis;
  final String primaryGenreName;

  Song({
    required this.trackId,
    required this.trackName,
    required this.artistName,
    required this.collectionName,
    required this.artworkUrl100,
    this.previewUrl,
    required this.trackPrice,
    required this.releaseDate,
    required this.trackTimeMillis,
    required this.primaryGenreName,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      trackId: json['trackId'] ?? 0,
      trackName: json['trackName'] ?? 'Unknown',
      artistName: json['artistName'] ?? 'Unknown Artist',
      collectionName: json['collectionName'] ?? 'Unknown Album',
      artworkUrl100: json['artworkUrl100'] ?? '',
      previewUrl: json['previewUrl'],
      trackPrice: (json['trackPrice'] ?? 0.0).toDouble(),
      releaseDate: json['releaseDate'] ?? '',
      trackTimeMillis: json['trackTimeMillis'] ?? 0,
      primaryGenreName: json['primaryGenreName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trackId': trackId,
      'trackName': trackName,
      'artistName': artistName,
      'collectionName': collectionName,
      'artworkUrl100': artworkUrl100,
      'previewUrl': previewUrl,
      'trackPrice': trackPrice,
      'releaseDate': releaseDate,
      'trackTimeMillis': trackTimeMillis,
      'primaryGenreName': primaryGenreName,
    };
  }

  String get duration {
    final seconds = trackTimeMillis ~/ 1000;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}