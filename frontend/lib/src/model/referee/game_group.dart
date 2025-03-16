import 'package:tournament_manager/src/model/referee/game.dart';

class GameGroup {
  GameGroup(
    this.startTime,
    this.gameDurationInMinutes,
  );

  DateTime startTime;
  int gameDurationInMinutes;
  List<Game> games = [];
}
