import 'package:tournament_manager/src/model/results/result_entry.dart';

class League {
  League(this.leagueNo);

  int leagueNo;
  List<ResultEntry> gameResults = [];
}
