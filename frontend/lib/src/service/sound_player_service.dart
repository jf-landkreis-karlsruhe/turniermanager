import 'package:audioplayers/audioplayers.dart';

abstract class SoundPlayerService {
  void playSound(Sounds sound);
}

class SoundPlayerServiceImplementation implements SoundPlayerService {
  final _player = AudioPlayer();

  @override
  void playSound(Sounds sound) async {
    AssetSource? source;

    switch (sound) {
      case Sounds.gong:
        source = AssetSource('sounds/gong_sound.wav');
        break;
      case Sounds.endMusic:
        break;
      default:
    }

    if (source == null) {
      return;
    }

    await _player.play(source);
  }
}

enum Sounds {
  gong,
  endMusic;
}
