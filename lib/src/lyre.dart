import 'dart:io';

import 'package:cli_annotations/cli_annotations.dart';
import 'package:kuroshiro/kuroshiro.dart';
import 'package:lyre/src/models/song.dart';
import 'package:lyre/src/musixmatch.dart';

part 'lyre.g.dart';

/// Download (and optionally normalises) lyrics files from MusixMatchs.
@cliRunner
class Lyre extends _$Lyre<int> {
  static var musixmatch = Musixmatch(token: '25070e2670967e9ec01b2aaf14d4dc278321f799d5f67468c1c2');

  @cliCommand
  Future<int> download({
    @MultiOption(abbr: 'a', help: 'The artists to search') required List<String> artists,

    @MultiOption(abbr: 's', help: 'The songs to search') required List<String> songs,

    @Option(help: 'The musixmatch api token') String? token,

    Mode mode = Mode.normal,
  }) async {
    if (token != null) {
      musixmatch = Musixmatch(token: token);
    }

    if (mode != Mode.normal) {
      musixmatch.kuroshiro = await Kuroshiro().init();
    }

    for (int i = 0; i < artists.length; i++) {
      final artist = artists[i];
      final title = songs[i];
      var song = Song(artist: artist, title: title);

      final body = await musixmatch.findLyrics(song);
      if (body == null) {
        print('Couldnt find song');
        return 1;
      }
      song = Song.parse(body);
      song = musixmatch.getSynced(song, body);
      song = musixmatch.getUnsynced(song, body);
      final lrc = await musixmatch.genLrc(song, mode: mode);

      if (lrc == null) {
        print('Failed to generate lyrics');
        return 1;
      }

      final dir = await Directory('lyrics/${song.artist}').create(recursive: true);

      await File('${dir.path}/${song.title}.lrc').writeAsString(lrc);
    }
    return 0;
  }
}

enum Mode { normal, romanize, romanizeOnly }
