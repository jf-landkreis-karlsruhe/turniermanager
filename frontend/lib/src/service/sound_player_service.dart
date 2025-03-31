import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:watch_it/watch_it.dart';

abstract class SoundPlayerService implements Disposable {
  void playSound(Sounds sound);
}

class SoundPlayerServiceImplementation implements SoundPlayerService {
  final _player = AudioPlayer();

  @override
  void playSound(Sounds sound) async {
    if (_player.state == PlayerState.playing) {
      return;
    }

    String? soundPath;

    switch (sound) {
      case Sounds.gong:
        soundPath = 'sounds/gong_sound.wav';
        break;
      case Sounds.horn:
        soundPath = 'sounds/horn.wav';
        break;
      case Sounds.endMusic:
        soundPath = 'sounds/end_of_game.wav';
        break;
      default:
    }

    if (soundPath == null || soundPath.isEmpty) {
      return;
    }

    try {
      await _player.play(AssetSource(soundPath));
    } on Exception {
      return;
    }
  }

  @override
  FutureOr onDispose() async {
    await _player.stop();
    await _player.dispose();
  }
}

enum Sounds {
  gong,
  horn,
  endMusic;
}
