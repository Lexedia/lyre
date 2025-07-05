// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lyre.dart';

// **************************************************************************
// CliRunnerGenerator
// **************************************************************************

/// Download (and optionally normalises) lyrics files from MusixMatchs.
///
/// A class for invoking [Command]s based on raw command-line arguments.
///
/// The type argument `T` represents the type returned by [Command.run] and
/// [CommandRunner.run]; it can be ommitted if you're not using the return
/// values.
class _$Lyre<T extends dynamic> extends CommandRunner<int> {
  _$Lyre()
      : super(
          'lyre',
          'Download (and optionally normalises) lyrics files from MusixMatchs.',
        ) {
    final upcastedType = (this as Lyre);
    addCommand(DownloadCommand(upcastedType.download));
  }

  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    try {
      return await super.runCommand(topLevelResults);
    } on UsageException catch (e) {
      stdout.writeln('${e.message}\n');
      stdout.writeln(e.usage);
    }
  }
}

class DownloadCommand extends Command<int> {
  DownloadCommand(this.userMethod) {
    argParser
      ..addMultiOption(
        'artists',
        abbr: 'a',
        help: 'The artists to search',
      )
      ..addMultiOption(
        'songs',
        abbr: 's',
        help: 'The songs to search',
      )
      ..addOption(
        'token',
        help: 'The musixmatch api token',
        mandatory: false,
      )
      ..addOption(
        'mode',
        defaultsTo: 'normal',
        mandatory: false,
        allowed: [
          'normal',
          'romanize',
          'romanizeOnly',
        ],
      );
  }

  final Future<int> Function({
    required List<String> artists,
    required List<String> songs,
    String? token,
    Mode mode,
  }) userMethod;

  @override
  String get name => 'download';

  @override
  String get description => '';

  @override
  Future<int> run() {
    final results = argResults!;
    return userMethod(
      artists: List<String>.from(results['artists']),
      songs: List<String>.from(results['songs']),
      token: (results['token'] as String?) ?? null,
      mode: results['mode'] != null
          ? EnumParser(Mode.values).parse(results['mode'])
          : Mode.normal,
    );
  }
}
