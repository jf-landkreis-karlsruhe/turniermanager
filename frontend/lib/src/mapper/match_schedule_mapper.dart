import 'package:tournament_manager/src/model/match_schedule.dart';
import 'package:tournament_manager/src/model/match_schedule_entry.dart';
import 'package:tournament_manager/src/serialization/match_schedule_dto.dart';

class MatchScheduleMapper {
  MatchSchedule map(MatchScheduleDto dto) {
    return MatchSchedule()
      ..entries = dto.entries
          .map((entry) => MatchScheduleEntry(
                entry.field,
                entry.team1,
                entry.pointsTeam1,
                entry.team2,
                entry.pointsTeam2,
                entry.startTime,
              ))
          .toList();
  }
}
