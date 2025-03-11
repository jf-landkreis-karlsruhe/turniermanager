import 'package:tournament_manager/src/model/referee/game.dart';

class GameGroup {
  GameGroup(this.startTime);

  DateTime startTime;
  List<Game> games = [];
}
