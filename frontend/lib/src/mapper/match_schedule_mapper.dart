import 'package:tournament_manager/src/model/schedule/league.dart';
import 'package:tournament_manager/src/model/schedule/match_schedule.dart';
import 'package:tournament_manager/src/model/schedule/match_schedule_entry.dart';
import 'package:tournament_manager/src/serialization/schedule/league_dto.dart';
import 'package:tournament_manager/src/serialization/schedule/match_schedule_dto.dart';
import 'package:tournament_manager/src/serialization/schedule/match_schedule_entry_dto.dart';

class MatchScheduleMapper {
  MatchSchedule map(MatchScheduleDto dto) {
    return MatchSchedule(dto.matchRound)
      ..leagueSchedules =
          dto.leagueSchedules.map((entry) => mapLeague(entry)).toList();
  }

  League mapLeague(LeagueDto dto) {
    return League(dto.leagueNo)
      ..scheduledGames =
          dto.scheduledGames.map((entry) => mapEntry(entry)).toList();
  }

  MatchScheduleEntry mapEntry(MatchScheduleEntryDto dto) {
    return MatchScheduleEntry(
      dto.field,
      dto.team1,
      dto.team2,
      dto.startTime,
    );
  }
}
