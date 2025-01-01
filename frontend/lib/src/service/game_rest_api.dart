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
    int fieldCount = 1;
    int teamCount = 1;
    int hourCount = 10;
    int timeCount = 10;

    var scheduleList = List.generate(
      10,
      (innerIndex) {
        var result = MatchScheduleEntryDto(
          "$fieldCount",
          "team${teamCount++}",
          1,
          "team${teamCount++}",
          2,
          "$hourCount:$timeCount Uhr",
        );

        fieldCount++;
        if (fieldCount > 3) {
          fieldCount = 1;
        }

        if (teamCount > 4) {
          teamCount = 1;
        }

        timeCount += 10;
        if (timeCount >= 60) {
          timeCount = 10;
          hourCount++;
        }

        return result;
      },
    );

    return MatchScheduleDto(1)
      ..leagueSchedules = List.generate(
        3,
        (index) {
          return LeagueDto(index + 1)..scheduledGames = scheduleList;
        },
      );

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
