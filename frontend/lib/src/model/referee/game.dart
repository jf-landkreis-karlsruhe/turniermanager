import 'package:tournament_manager/src/model/referee/pitch.dart';
import 'package:tournament_manager/src/model/referee/team.dart';

class Game {
  Game(
    this.gameNumber,
    this.pitch,
    this.teamA,
    this.teamB,
    this.leagueName,
    this.ageGroupName,
  );

  int gameNumber;
  Pitch pitch;
  Team teamA;
  Team teamB;
  String leagueName;
  String ageGroupName;
}
