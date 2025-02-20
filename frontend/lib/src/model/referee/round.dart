import 'package:tournament_manager/src/model/referee/game.dart';

class Round {
  Round(
    this.name,
  );

  String name;
  List<Game> games = [];
}
