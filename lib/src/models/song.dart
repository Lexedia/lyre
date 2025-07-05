import 'package:lyre/src/models/subtitle.dart';

class Song {
  final String artist;
  final String title;
  final String? album;
  final Uri? uri;
  final Duration duration;
  final bool hasSynced;
  final bool hasUnsynced;
  final bool isInstrumental;
  final List<({String text, Duration duration})>? lyrics;
  final List<({String text, Duration duration})> subtitles;
  final String? coverartUrl;

  const Song({
    required this.artist,
    required this.title,
    this.album,
    this.uri,
    this.coverartUrl,
    this.duration = const Duration(),
    this.hasSynced = false,
    this.hasUnsynced = false,
    this.isInstrumental = false,
    this.lyrics,
    this.subtitles = const [],
  });

  static Song parse(Map raw) {
    final meta = (raw['matcher.track.get'] as Map)['message']['body'] as Map?;
    if (meta == null) {
      throw Exception('???');
    }

    final coverartSizes = ["100x100", "350x350", "500x500", "800x800"];
    final coverartUrls = [for (final size in coverartSizes) meta['track']['album_coverart_$size']];

    return Song(
      artist: meta['track']['artist_name'],
      title: meta['track']['track_name'],
      coverartUrl: coverartUrls.lastOrNull,
      album: meta['track']['album_name'],
      duration: Duration(seconds: meta['track']['track_length']),
      hasSynced: meta['track']['has_subtitles'] == 1,
      hasUnsynced: meta['track']['has_lyrics'] == 1,
      isInstrumental: meta['track']['instrumental'] == 1,
    );
  }

  Song copyWith({
    String? artist,
    String? title,
    String? album,
    Uri? uri,
    Duration? duration,
    bool? hasSynced,
    bool? hasUnsynced,
    bool? isInstrumental,
    List<({String text, Duration duration})>? lyrics,
    List<({String text, Duration duration})>? subtitles,
    String? coverartUrl,
  }) {
    return Song(
      artist: artist ?? this.artist,
      title: title ?? this.title,
      album: album ?? this.album,
      uri: uri ?? this.uri,
      coverartUrl: coverartUrl ?? this.coverartUrl,
      duration: duration ?? this.duration,
      hasSynced: hasSynced ?? this.hasSynced,
      hasUnsynced: hasUnsynced ?? this.hasUnsynced,
      isInstrumental: isInstrumental ?? this.isInstrumental,
      lyrics: lyrics ?? this.lyrics,
      subtitles: subtitles ?? this.subtitles,
    );
  }
}
