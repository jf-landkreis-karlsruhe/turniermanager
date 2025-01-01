import 'package:tournament_manager/src/model/match_schedule_entry.dart';

class League {
  League(this.leagueNo);

  int leagueNo;
  List<MatchScheduleEntry> scheduledGames = [];
}
