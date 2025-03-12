import 'package:tournament_manager/src/model/schedule/league.dart';

class MatchSchedule {
  MatchSchedule(this.roundName);

  String roundName;
  List<League> leagueSchedules = [];
}
