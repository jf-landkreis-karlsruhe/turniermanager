import 'package:tournament_manager/src/model/referee/game_settings.dart';

class RoundSettings {
  RoundSettings(this.gameSettings);

  Map<String, int> numberPerRounds = {};
  GameSettings gameSettings;
}
