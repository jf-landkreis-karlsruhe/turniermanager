import 'package:audioplayers/audioplayers.dart';

abstract class SoundPlayerService {
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

    await _player.play(AssetSource(soundPath));
  }
}

enum Sounds {
  gong,
  horn,
  endMusic;
}
