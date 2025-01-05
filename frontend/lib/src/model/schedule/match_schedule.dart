import 'package:tournament_manager/src/model/schedule/league.dart';

class MatchSchedule {
  MatchSchedule(this.matchRound);

  int matchRound;
  List<League> leagueSchedules = [];
}
