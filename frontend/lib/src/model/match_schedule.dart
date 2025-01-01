import 'package:tournament_manager/src/model/league.dart';

class MatchSchedule {
  MatchSchedule(this.matchRound);

  int matchRound;
  List<League> leagueSchedules = [];
}
