import 'dart:convert';
import 'package:tournament_manager/src/serialization/results/result_entry_dto.dart';
import 'package:tournament_manager/src/serialization/results/results_dto.dart';
import 'package:tournament_manager/src/serialization/schedule/league_dto.dart';
import 'package:tournament_manager/src/serialization/results/league_dto.dart'
    as resultleague;
import 'package:tournament_manager/src/serialization/schedule/match_schedule_dto.dart';
import 'package:tournament_manager/src/serialization/schedule/match_schedule_entry_dto.dart';
import 'package:tournament_manager/src/service/rest_client.dart';

abstract class GameRestApi {
  Future<MatchScheduleDto?> getSchedule(String ageGroup);

  Future<ResultsDto?> getResults(String ageGroup);
}

class GameRestApiImplementation extends RestClient implements GameRestApi {
  late final Uri getScheduleUri;
  late final Uri getResultsUri;

  GameRestApiImplementation() {
    getScheduleUri = Uri.parse('$baseUri/schedule');
    getResultsUri = Uri.parse('$baseUri/results');
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
          "team${teamCount++}",
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

  @override
  Future<ResultsDto?> getResults(String ageGroup) async {
    //TODO: remove test data

    var scheduleList = List.generate(
      10,
      (innerIndex) {
        var result = ResultEntryDto(
          'teamName',
          1,
          1,
          1,
          1,
          1,
          1,
        );

        return result;
      },
    );

    return ResultsDto(1)
      ..leagueResults = List.generate(
        3,
        (index) {
          return resultleague.LeagueDto(index + 1)..gameResults = scheduleList;
        },
      );

    final uri = getResultsUri.replace(
      queryParameters: {
        'ageGroup': ageGroup,
      },
    );

    final response = await client.get(uri, headers: headers);

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      return ResultsDto.fromJson(json);
    }

    return null;
  }
}
