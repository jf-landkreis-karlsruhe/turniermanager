import 'dart:convert';
import 'dart:math';
import 'package:tournament_manager/src/serialization/referee/age_group_dto.dart';
import 'package:tournament_manager/src/serialization/referee/game_dto.dart';
import 'package:tournament_manager/src/serialization/referee/game_group_dto.dart';
import 'package:tournament_manager/src/serialization/referee/pitch_dto.dart';
import 'package:tournament_manager/src/serialization/referee/team_dto.dart';
import 'package:tournament_manager/src/serialization/results/result_entry_dto.dart';
import 'package:tournament_manager/src/serialization/results/results_dto.dart';
import 'package:tournament_manager/src/serialization/schedule/league_dto.dart';
import 'package:tournament_manager/src/serialization/results/league_dto.dart'
    as resultleague;
import 'package:tournament_manager/src/serialization/schedule/match_schedule_dto.dart';
import 'package:tournament_manager/src/serialization/schedule/match_schedule_entry_dto.dart';
import 'package:tournament_manager/src/service/rest_client.dart';

abstract class GameRestApi {
  Future<MatchScheduleDto?> getSchedule(String ageGroupId);

  Future<ResultsDto?> getResults(String ageGroupId);

  Future<bool?> startCurrentGames();

  Future<bool?> endCurrentGames();

  Future<bool?> startNextRound();

  Future<List<GameGroupDto>> getCurrentRound();

  Future<List<AgeGroupDto>> getAllAgeGroups();
}

class GameRestApiImplementation extends RestClient implements GameRestApi {
  late final String getSchedulePath;
  late final String getResultsPath;
  late final Uri getAllAgeGroupsUri;
  late final Uri getAllGameGroupsUri;

  GameRestApiImplementation() {
    getSchedulePath = '$baseUri/gameplan/agegroup/';
    getResultsPath = '$baseUri/stats/agegroup/';
    getAllAgeGroupsUri = Uri.parse('$baseUri/turniersetup/agegroups/getAll');
    getAllGameGroupsUri =
        Uri.parse('$baseUri/games/activeGamesSortedDateTimeList');
  }

  @override
  Future<MatchScheduleDto?> getSchedule(String ageGroupId) async {
    final uri = Uri.parse(getSchedulePath + ageGroupId);

    final response = await client.get(uri, headers: headers);

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      return MatchScheduleDto.fromJson(json);
    }

    return null;
  }

  @override
  Future<ResultsDto?> getResults(String ageGroupId) async {
    final uri = Uri.parse(getSchedulePath + ageGroupId);

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
  Future<List<AgeGroupDto>> getAllAgeGroups() async {
    final response = await client.get(getAllAgeGroupsUri, headers: headers);

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);

      if (json is List<Map<String, dynamic>>) {
        return json.map((e) => AgeGroupDto.fromJson(e)).toList();
      }
    }

    return [];
  }

  @override
  Future<List<GameGroupDto>> getCurrentRound() async {
    final response = await client.get(getAllGameGroupsUri, headers: headers);

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);

      if (json is List<Map<String, dynamic>>) {
        return json.map((e) => GameGroupDto.fromJson(e)).toList();
      }
    }

    return [];
  }
}

class GameTestRestApi extends GameRestApi {
  @override
  Future<bool?> endCurrentGames() async {
    return true;
  }

  @override
  Future<List<AgeGroupDto>> getAllAgeGroups() async {
    return [
      AgeGroupDto('', 'Altersklasse 1'),
      AgeGroupDto('', 'Altersklasse 2'),
      AgeGroupDto('', 'Altersklasse 3'),
    ];
  }

  @override
  Future<List<GameGroupDto>> getCurrentRound() async {
    return [
      GameGroupDto(DateTime.now())
        ..games = [
          GameDto(
            1,
            PitchDto("Feld 1"),
            TeamDto("Team A"),
            TeamDto("Team B"),
            'Liga 1',
            'Altersklasse 1',
          ),
          GameDto(
            1,
            PitchDto("Feld 2"),
            TeamDto("Team A"),
            TeamDto("Team B"),
            'Liga 1',
            'Altersklasse 2',
          ),
          GameDto(
            2,
            PitchDto("Feld 1"),
            TeamDto("Team A"),
            TeamDto("Team B"),
            'Liga 2',
            'Altersklasse 1',
          ),
          GameDto(
            2,
            PitchDto("Feld 2"),
            TeamDto("Team A"),
            TeamDto("Team B"),
            'Liga 2',
            'Altersklasse 2',
          ),
        ],
      GameGroupDto(DateTime.now())
        ..games = [
          GameDto(
            1,
            PitchDto("Feld 1"),
            TeamDto("Team A"),
            TeamDto("Team B"),
            'Liga 1',
            'Altersklasse 1',
          ),
          GameDto(
            1,
            PitchDto("Feld 2"),
            TeamDto("Team A"),
            TeamDto("Team B"),
            'Liga 3',
            'Altersklasse 1',
          ),
          GameDto(
            2,
            PitchDto("Feld 1"),
            TeamDto("Team A"),
            TeamDto("Team B"),
            'Liga 1',
            'Altersklasse 4',
          ),
          GameDto(
            2,
            PitchDto("Feld 2"),
            TeamDto("Team A"),
            TeamDto("Team B"),
            'Liga 5',
            'Altersklasse 1',
          ),
        ],
    ];
  }

  @override
  Future<ResultsDto?> getResults(String ageGroupId) async {
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
      (a, b) => a.totalPoints.compareTo(b.totalPoints),
    );

    return ResultsDto('Runde 1')
      ..leagueTables = List.generate(
        3,
        (index) {
          return resultleague.LeagueDto('Liga ${index + 1}')
            ..teams = resultList.reversed.toList();
        },
      );
  }

  @override
  Future<MatchScheduleDto?> getSchedule(String ageGroupId) async {
    int fieldCount = 1;
    int teamCount = 1;
    int hourCount = 10;
    int timeCount = 10;

    var scheduleList = List.generate(
      10,
      (innerIndex) {
        var result = MatchScheduleEntryDto(
          "Platz $fieldCount",
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
      ..leagues = List.generate(
        8,
        (index) {
          return LeagueDto('Liga ${index + 1}')..entries = scheduleList;
        },
      );
  }

  @override
  Future<bool?> startCurrentGames() async {
    return true;
  }

  @override
  Future<bool?> startNextRound() async {
    return true;
  }
}
