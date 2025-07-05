import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kuroshiro/kuroshiro.dart';
import 'package:lyre/src/lyre.dart';
import 'package:lyre/src/models/song.dart';

class Musixmatch {
  static final Uri baseUri = Uri.https('apic-desktop.musixmatch.com', '/ws/1.1/macro.subtitles.get', {
    'format': 'json',
    'namespace': 'lyrics_richsynched',
    'subtitle_format': 'mxm',
    'app_id': 'web-desktop-app-v1.0',
  });

  static const Map<String, String> headers = {'Authority': 'apic-desktop.musixmatch.com', 'Cookie': 'x-mxm-token-guid='};

  final String token;

  late Kuroshiro kuroshiro;

  Musixmatch({required this.token});

  Future<Map?> findLyrics(Song song) async {
    final params = {'q_album': song.album, 'q_artist': song.artist, 'q_track': song.title, 'usertoken': token};
    final uri = baseUri.replace(queryParameters: {...baseUri.queryParameters, ...params});

    final response = await http.get(uri, headers: headers);

    final r = json.decode(response.body);

    if (r['message']?['header']?['status_code'] != 200 && r['message']?['header']?['hint'] == 'renew') {
      print('Invalid token');
      return null;
    }

    final body = r['message']['body']['macro_calls'];

    if (body['matcher.track.get']['message']['header']['status_code'] != 200) {
      if (body['matcher.track.get']['message']['header']['status_code'] == 404) {
        print('Song not found.');
      } else if (body['matcher.track.get']['message']['header']['status_code'] == 401) {
        print('Timed out. Change the token or wait a few minutes before trying again.');
      } else {
        print('Requested error: ${body['matcher.track.get']['message']['header']}');
      }
      return null;
    }

    return body;
  }

  Song getUnsynced(Song song, Map body) {
    List<({String text, Duration duration})> lines = [];
    if (song.isInstrumental) {
      lines = [(duration: Duration.zero, text: '♪ Instrumental ♪')];
    } else if (song.hasUnsynced) {
      final lyricsBody = body["track.lyrics.get"]["message"]['body'];
      if (lyricsBody == null) {
        return song;
      }
      final lyrics = lyricsBody["lyrics"]["lyrics_body"];
      if (lyrics != null) {
        lines = [for (final line in (lyrics as String).split('\n')) (duration: Duration.zero, text: line)];
      } else {
        lines = [(duration: Duration.zero, text: '')];
      }
    }
    return song.copyWith(lyrics: lines);
  }

  Song getSynced(Song song, Map body) {
    List<({String text, Duration duration})> lines = [];
    if (song.isInstrumental) {
      lines = [(duration: Duration.zero, text: '♪ Instrumental ♪')];
    } else if (song.hasSynced) {
      var subtitleBody = body["track.subtitles.get"]?["message"]?["body"];
      if (subtitleBody == null) {
        return song;
      }
      final subtitle = subtitleBody['subtitle_list']?[0]?['subtitle'];
      if (subtitle != null) {
        lines = [
          for (final line in json.decode(subtitle['subtitle_body']))
            (
              duration: Duration(milliseconds: line['time']['hundredths'], minutes: line['time']['minutes'], seconds: line['time']['seconds']),
              text: (line['text']?.isEmpty ?? true) ? '♪' : line['text'],
            ),
        ];
      } else {
        lines = [(duration: Duration.zero, text: '')];
      }
    }
    return song.copyWith(subtitles: lines);
  }

  Future<String?> genLrc(Song song, {Mode mode = Mode.normal}) async {
    var lyrics = song.subtitles;
    if (lyrics.isEmpty) {
      lyrics = song.lyrics ?? [];
      if (lyrics.isEmpty) {
        print('No lyrics found');
        return null;
      }
    }

    final sb = StringBuffer();

    sb.writeln('[ar:${song.artist}]');
    sb.writeln('[ti:${song.title}]');
    if (song.album != null) {
      sb.writeln('[al:${song.album}]');
    }
    if (song.duration case final duration when duration > const Duration()) {
      sb.writeln('[length:${duration.fmt()}]');
    }

    for (final lrc in lyrics) {
      final text = switch (mode) {
        Mode.normal => lrc.text,
        Mode.romanizeOnly => await kuroshiro.convert(lrc.text, mode: ConvertMode.spaced, to: ConvertTo.romaji),
        Mode.romanize => '${lrc.text} (${await kuroshiro.convert(lrc.text, mode: ConvertMode.spaced, to: ConvertTo.romaji)})',
      };
      sb.writeln('[${lrc.duration.fmt()}]$text');
    }

    return sb.toString();
  }
}

extension on Duration {
  String fmt() {
    var ms = inMicroseconds;
    var minutes = ms ~/ Duration.microsecondsPerMinute;
    ms = ms.remainder(Duration.microsecondsPerMinute);
    var seconds = ms ~/ Duration.microsecondsPerSecond;
    ms = ms.remainder(Duration.microsecondsPerSecond);
    var milliseconds = ms ~/ Duration.microsecondsPerMillisecond;

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${milliseconds.toString().padLeft(2, '0')}';
  }
}
