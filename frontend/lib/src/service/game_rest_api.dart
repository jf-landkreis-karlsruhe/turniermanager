import 'dart:convert';
import 'dart:math';
import 'package:download/download.dart';
import 'package:tournament_manager/src/serialization/admin/extended_game_dto.dart';
import 'package:tournament_manager/src/serialization/age_group_dto.dart';
import 'package:tournament_manager/src/serialization/referee/break_request_dto.dart';
import 'package:tournament_manager/src/serialization/referee/game_dto.dart';
import 'package:tournament_manager/src/serialization/referee/game_group_dto.dart';
import 'package:tournament_manager/src/serialization/referee/pitch_dto.dart';
import 'package:tournament_manager/src/serialization/referee/team_dto.dart';
import 'package:tournament_manager/src/serialization/referee/timing_request_dto.dart';
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

  Future<bool> endCurrentGames(
    DateTime originalStart,
    DateTime actualStart,
    DateTime end,
  );

  Future<bool> startNextRound(int maxTeams);

  Future<List<GameGroupDto>> getCurrentRound();

  Future<List<AgeGroupDto>> getAllAgeGroups();

  Future<List<ExtendedGameDto>> getAllGames();
  Future<bool> saveGame(int gameNumber, int teamAScore, int teamBScore);

  Future<bool> addBreak(DateTime start, int durationInMinutes);

  Future<List<PitchDto>> getAllPitches();
  Future<bool> printPitch(String pitchId);
}

class GameRestApiImplementation extends RestClient implements GameRestApi {
  late final String _baseUri;

  late final String getSchedulePath;
  late final String getResultsPath;
  late final Uri getAllAgeGroupsUri;
  late final Uri getAllGameGroupsUri;
  late final Uri createRoundUri;
  late final Uri endGamesUri;
  late final Uri getAllGamesUri;
  late final String saveGamePath;
  late final Uri addBreakUri;
  late final Uri getAllPitchesUri;
  late final String printPitchPath;

  GameRestApiImplementation(String baseUri) {
    _baseUri = baseUri;

    getSchedulePath = '$_baseUri/gameplan/agegroup/';
    getResultsPath = '$_baseUri/stats/agegroup/';
    getAllAgeGroupsUri = Uri.parse('$_baseUri/turniersetup/agegroups/getAll');
    getAllGameGroupsUri =
        Uri.parse('$_baseUri/games/activeGamesSortedDateTimeList');
    createRoundUri = Uri.parse('$_baseUri/turniersetup/create/round');
    endGamesUri = Uri.parse('$_baseUri/games/refreshTimings');
    getAllGamesUri = Uri.parse('$_baseUri/games/getAll');
    saveGamePath = '$_baseUri/games/update/';
    addBreakUri = Uri.parse('$_baseUri/turniersetup/addBreak');
    getAllPitchesUri = Uri.parse('$_baseUri/turniersetup/pitches');
    printPitchPath = '$_baseUri/turniersetup/pitches/result-card/';
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
    final uri = Uri.parse(getResultsPath + ageGroupId);

    final response = await client.get(uri, headers: headers);

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      return ResultsDto.fromJson(json);
    }

    return null;
  }

  @override
  Future<bool> endCurrentGames(
    DateTime originalStart,
    DateTime actualStart,
    DateTime end,
  ) async {
    var dto = TimingRequestDto(
      originalStart,
      actualStart,
      end,
    );

    var serialized = jsonEncode(dto);

    try {
      final response = await client.post(
        endGamesUri,
        body: serialized,
        headers: headers,
      );

      if (response.statusCode == 200) {
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> startNextRound(int maxTeams) async {
    try {
      var uri = createRoundUri.replace(queryParameters: {
        "maxTeamsPerLeague": maxTeams.toString(),
      });

      final response = await client.post(uri, headers: headers);

      if (response.statusCode == 200) {
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<AgeGroupDto>> getAllAgeGroups() async {
    final response = await client.get(getAllAgeGroupsUri, headers: headers);

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);

      if (json is List) {
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

      if (json is List) {
        return json.map((e) => GameGroupDto.fromJson(e)).toList();
      }
    }

    return [];
  }

  @override
  Future<List<ExtendedGameDto>> getAllGames() async {
    final response = await client.get(getAllGamesUri, headers: headers);

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);

      if (json is List) {
        return json.map((e) => ExtendedGameDto.fromJson(e)).toList();
      }
    }

    return [];
  }

  @override
  Future<bool> saveGame(int gameNumber, int teamAScore, int teamBScore) async {
    try {
      final uri = Uri.parse(saveGamePath + gameNumber.toString());
      uri.replace(
        queryParameters: {
          'teamAScore': teamAScore.toString(),
          'teamBScore': teamBScore.toString(),
        },
      );

      final response = await client.post(uri, headers: headers);

      if (response.statusCode == 200) {
        return true;
      }

      return false;
    } on Exception {
      return false;
    }
  }

  @override
  Future<bool> addBreak(DateTime start, int durationInMinutes) async {
    try {
      var dto = BreakRequestDto(start, durationInMinutes);
      var serialized = jsonEncode(dto);

      final response = await client.post(
        addBreakUri,
        body: serialized,
        headers: headers,
      );

      if (response.statusCode == 200) {
        return true;
      }

      return false;
    } on Exception {
      return false;
    }
  }

  @override
  Future<List<PitchDto>> getAllPitches() async {
    final response = await client.get(getAllPitchesUri, headers: headers);

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);

      if (json is List) {
        return json.map((e) => PitchDto.fromJson(e)).toList();
      }
    }

    return [];
  }

  @override
  Future<bool> printPitch(String pitchId) async {
    try {
      final uri = Uri.parse(printPitchPath + pitchId);

      final response = await client.get(uri, headers: headers);

      if (response.statusCode == 200) {
        String fileName = 'Schiedsrichterzettel_Platz_$pitchId.pdf';

        final stream = Stream.fromIterable(response.bodyBytes);
        await download(stream, fileName);
        return true;
      }

      return false;
    } on Exception {
      return false;
    }
  }
}

class GameTestRestApi extends GameRestApi {
  @override
  Future<bool> endCurrentGames(
    DateTime originalStart,
    DateTime actualStart,
    DateTime end,
  ) async {
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
      GameGroupDto(
        DateTime.now(),
        10,
      )..games = [
          GameDto(
            1,
            PitchDto('1', "Feld 1"),
            TeamDto("Team A"),
            TeamDto("Team B"),
            'Liga 1',
            'Altersklasse 1',
          ),
          GameDto(
            1,
            PitchDto('2', "Feld 2"),
            TeamDto("Team A"),
            TeamDto("Team B"),
            'Liga 1',
            'Altersklasse 2',
          ),
          GameDto(
            2,
            PitchDto('1', "Feld 1"),
            TeamDto("Team A"),
            TeamDto("Team B"),
            'Liga 2',
            'Altersklasse 1',
          ),
          GameDto(
            2,
            PitchDto('2', "Feld 2"),
            TeamDto("Team A"),
            TeamDto("Team B"),
            'Liga 2',
            'Altersklasse 2',
          ),
        ],
      GameGroupDto(
        DateTime.now(),
        12,
      )..games = [
          GameDto(
            1,
            PitchDto('1', "Feld 1"),
            TeamDto("Team A"),
            TeamDto("Team B"),
            'Liga 1',
            'Altersklasse 1',
          ),
          GameDto(
            1,
            PitchDto('2', "Feld 2"),
            TeamDto("Team A"),
            TeamDto("Team B"),
            'Liga 3',
            'Altersklasse 1',
          ),
          GameDto(
            2,
            PitchDto('1', "Feld 1"),
            TeamDto("Team A"),
            TeamDto("Team B"),
            'Liga 1',
            'Altersklasse 4',
          ),
          GameDto(
            2,
            PitchDto('2', "Feld 2"),
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

    var scheduleList = List.generate(
      10,
      (innerIndex) {
        var result = MatchScheduleEntryDto(
          "Platz $fieldCount",
          "team${teamCount++}",
          "team${teamCount++}",
          DateTime.now(),
        );

        fieldCount++;
        if (fieldCount > 3) {
          fieldCount = 1;
        }

        if (teamCount > 4) {
          teamCount = 1;
        }

        return result;
      },
    );

    return MatchScheduleDto('Runde 1')
      ..leagues = List.generate(
        8,
        (index) {
          return LeagueDto('Liga ${index + 1}')..entries = scheduleList;
        },
      );
  }

  @override
  Future<bool> startNextRound(int maxTeams) async {
    return true;
  }

  @override
  Future<List<ExtendedGameDto>> getAllGames() async {
    return [
      ExtendedGameDto(
        1,
        'Platz 1',
        'Team 1',
        'Team 2',
        'Liga 1',
        'Altersklasse 1',
        2,
        3,
        DateTime.now().add(const Duration(minutes: 10)),
      ),
      ExtendedGameDto(
        2,
        'Platz 2',
        'Team 3',
        'Team 4',
        'Liga 2',
        'Altersklasse 2',
        5,
        6,
        DateTime.now(),
      ),
    ];
  }

  @override
  Future<bool> saveGame(int gameNumber, int teamAScore, int teamBScore) async {
    return true;
  }

  @override
  Future<bool> addBreak(DateTime start, int durationInMinutes) async {
    return true;
  }

  @override
  Future<List<PitchDto>> getAllPitches() async {
    return [
      PitchDto(
        '1',
        'Platz 1',
      ),
      PitchDto(
        '2',
        'Platz 2',
      ),
      PitchDto(
        '3',
        'Platz 3',
      ),
    ];
  }

  @override
  Future<bool> printPitch(String pitchId) async {
    return true;
  }
}
