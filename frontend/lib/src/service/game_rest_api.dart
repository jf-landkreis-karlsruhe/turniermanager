import 'dart:convert';
import 'package:tournament_manager/src/serialization/league_dto.dart';
import 'package:tournament_manager/src/serialization/match_schedule_dto.dart';
import 'package:tournament_manager/src/serialization/match_schedule_entry_dto.dart';
import 'package:tournament_manager/src/service/rest_client.dart';

abstract class GameRestApi {
  Future<MatchScheduleDto?> getSchedule(String ageGroup);
}

class GameRestApiImplementation extends RestClient implements GameRestApi {
  late final Uri getScheduleUri;

  GameRestApiImplementation() {
    getScheduleUri = Uri.parse('$baseUri/schedule');
  }

  @override
  Future<MatchScheduleDto?> getSchedule(String ageGroup) async {
    //TODO: remove test data
    return MatchScheduleDto()
      ..leagueSchedules = [
        LeagueDto(1)
          ..scheduledGames = [
            MatchScheduleEntryDto("1", "team1", 1, "team2", 2, "startTime1"),
            MatchScheduleEntryDto("2", "team3", 1, "team4", 2, "startTime2"),
          ],
        LeagueDto(2)
          ..scheduledGames = [
            MatchScheduleEntryDto("1", "team1", 1, "team2", 2, "startTime1"),
            MatchScheduleEntryDto("2", "team3", 1, "team4", 2, "startTime2"),
          ],
      ];

    final uri = getScheduleUri.replace(
      queryParameters: {
        'ageGroup': ageGroup,
      },
    );

    final response = await client.get(uri, headers: headers);

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      return MatchScheduleDto.fromJson(json);
    }

    return null;
  }
}
