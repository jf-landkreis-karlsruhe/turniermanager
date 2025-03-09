import 'package:tournament_manager/src/model/schedule/match_schedule_entry.dart';

class League {
  League(this.leagueName);

  String leagueName;
  List<MatchScheduleEntry> entries = [];
}
