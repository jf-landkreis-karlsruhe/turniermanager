import 'dart:convert';
import 'dart:math';
import 'package:tournament_manager/src/serialization/referee/age_group_dto.dart';
import 'package:tournament_manager/src/serialization/referee/game_dto.dart';
import 'package:tournament_manager/src/serialization/referee/pitch_dto.dart';
import 'package:tournament_manager/src/serialization/referee/round_dto.dart';
import 'package:tournament_manager/src/serialization/referee/team_dto.dart';
import 'package:tournament_manager/src/serialization/results/result_entry_dto.dart';
import 'package:tournament_manager/src/serialization/results/results_dto.dart';
import 'package:tournament_manager/src/serialization/schedule/league_dto.dart';
import 'package:tournament_manager/src/serialization/results/league_dto.dart'
    as resultleague;
import 'package:tournament_manager/src/serialization/schedule/match_schedule_dto.dart';
import 'package:tournament_manager/src/serialization/schedule/match_schedule_entry_dto.dart';
import 'package:tournament_manager/src/service/rest_client.dart';
import 'package:tournament_manager/src/serialization/referee/league_dto.dart'
    as referee_league;

abstract class GameRestApi {
  Future<MatchScheduleDto?> getSchedule(String ageGroup);

  Future<ResultsDto?> getResults(String ageGroup);

  Future<bool?> startCurrentGames();

  Future<bool?> endCurrentGames();

  Future<bool?> startNextRound();

  Future<RoundDto?> getCurrentRound();

  Future<List<AgeGroupDto>> getAllAgeGroups();
}

class GameRestApiImplementation extends RestClient implements GameRestApi {
  late final Uri getScheduleUri;
  late final Uri getResultsUri;
  late final Uri getAllAgeGroupsUri;

  GameRestApiImplementation() {
    getScheduleUri = Uri.parse('$baseUri/schedule');
    getResultsUri = Uri.parse('$baseUri/results');
    getAllAgeGroupsUri = Uri.parse('$baseUri/turniersetup/agegroups');
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
        8,
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

    var resultList = List.generate(
      10,
      (index) {
        var randomGenerator = Random(index);
        var result = ResultEntryDto(
          'Team$index',
          randomGenerator.nextInt(100),
          randomGenerator.nextInt(100),
          randomGenerator.nextInt(100),
          randomGenerator.nextInt(100),
          randomGenerator.nextInt(100),
          randomGenerator.nextInt(100),
        );

        return result;
      },
    );

    resultList.sort(
      (a, b) => a.points.compareTo(b.points),
    );

    return ResultsDto(1)
      ..leagueResults = List.generate(
        3,
        (index) {
          return resultleague.LeagueDto(index + 1)
            ..gameResults = resultList.reversed.toList();
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

  @override
  Future<bool?> endCurrentGames() async {
    try {
      return true; // TODO: implement endCurrentGames
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool?> startCurrentGames() async {
    try {
      return true; // TODO: implement endCurrentGames
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool?> startNextRound() async {
    try {
      return true; // TODO: implement endCurrentGames
    } catch (e) {
      return null;
    }
  }

  @override
  Future<RoundDto?> getCurrentRound() async {
    // TODO: implement getCurrentRound
    return RoundDto("Runde 1")
      ..games = [
        GameDto(
          1,
          PitchDto("1"),
          TeamDto(
            "Team A",
            AgeGroupDto("1"),
            referee_league.LeagueDto("1"),
          ),
          TeamDto(
            "Team B",
            AgeGroupDto("1"),
            referee_league.LeagueDto("1"),
          ),
        ),
        GameDto(
          1,
          PitchDto("2"),
          TeamDto(
            "Team A",
            AgeGroupDto("2"),
            referee_league.LeagueDto("1"),
          ),
          TeamDto(
            "Team B",
            AgeGroupDto("2"),
            referee_league.LeagueDto("1"),
          ),
        ),
        GameDto(
          2,
          PitchDto("1"),
          TeamDto(
            "Team A",
            AgeGroupDto("1"),
            referee_league.LeagueDto("1"),
          ),
          TeamDto(
            "Team B",
            AgeGroupDto("1"),
            referee_league.LeagueDto("1"),
          ),
        ),
        GameDto(
          2,
          PitchDto("2"),
          TeamDto(
            "Team A",
            AgeGroupDto("2"),
            referee_league.LeagueDto("2"),
          ),
          TeamDto(
            "Team B",
            AgeGroupDto("2"),
            referee_league.LeagueDto("2"),
          ),
        ),
      ];
  }

  @override
  Future<List<AgeGroupDto>> getAllAgeGroups() async {
    return getAllAgeGroupsTestData(); // TODO: remove test data

    final response = await client.get(getAllAgeGroupsUri, headers: headers);

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);

      if (json is List<Map<String, dynamic>>) {
        return json.map((e) => AgeGroupDto.fromJson(e)).toList();
      }
    }

    return [];
  }

  List<AgeGroupDto> getAllAgeGroupsTestData() {
    return [
      AgeGroupDto('Altersklasse 1'),
      AgeGroupDto('Altersklasse 2'),
      AgeGroupDto('Altersklasse 3'),
    ];
  }
}
