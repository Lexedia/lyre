import 'package:lyre/src/models/mixins.dart';

class Subtitle with ToMap, ToJson {
  final String text;
  final int minutes;
  final int seconds;
  final int hundredths;

  const Subtitle({required this.hundredths, required this.minutes, required this.seconds, required this.text});

  @override
  Map<String, Object> toMap() => {'text': text, 'minutes': minutes, 'seconds': seconds, 'hundredths': hundredths};

  Subtitle copyWith({String? text, int? minutes, int? seconds, int? hundredths}) =>
      Subtitle(hundredths: hundredths ?? this.hundredths, minutes: minutes ?? this.minutes, seconds: seconds ?? this.seconds, text: text ?? this.text);
}
