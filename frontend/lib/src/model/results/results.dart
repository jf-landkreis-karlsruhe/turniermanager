import 'package:tournament_manager/src/model/results/league.dart';

class Results {
  Results(this.matchRound);

  int matchRound;
  List<League> leagueResults = [];
}
