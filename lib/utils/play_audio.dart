import 'package:audioplayers/audioplayers.dart';

final player = AudioPlayer();
void playAudio(String character) async {
  final url =
      'https://translate.google.com/translate_tts?ie=UTF-8&q=$character&tl=zh-CN&client=tw-ob';
  await player.play(UrlSource(url));
}

void pauseAudio() async {
  await player.pause();
}
