import 'package:flutter/material.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:tournament_manager/src/mapper/match_schedule_mapper.dart';
import 'package:tournament_manager/src/mapper/referee_mapper.dart';
import 'package:tournament_manager/src/mapper/results_mapper.dart';
import 'package:tournament_manager/src/mapper/age_group_mapper.dart';
import 'package:tournament_manager/src/model/age_group.dart';
import 'package:tournament_manager/src/model/referee/game.dart';
import 'package:tournament_manager/src/model/referee/game_group.dart';
import 'package:tournament_manager/src/model/results/results.dart';
import 'package:tournament_manager/src/model/schedule/match_schedule.dart';
import 'package:tournament_manager/src/service/game_rest_api.dart';
import 'package:watch_it/watch_it.dart';

abstract class GameManager extends ChangeNotifier {
  late Command<String, void> getScheduleCommand;
  late Command<String, void> getResultsCommand;

  late Command<(DateTime originalStart, DateTime actualStart, DateTime end),
      bool> endCurrentGamesCommand;
  late Command<void, bool> startNextRoundCommand;
  late Command<void, void> getCurrentRoundCommand;

  late Command<void, void> getAgeGroupsCommand;

  late Command<void, void> getAllGamesCommand;
  late Command<(int gameNumber, int teamAScore, int teamBScore), void>
      saveGameCommand;

  AgeGroup? getAgeGroupByName(String name);

  MatchSchedule get schedule;
  Results get results;
  List<GameGroup> get gameGroups;
  List<AgeGroup> get ageGroups;

  List<Game> get games;
}

class GameManagerImplementation extends ChangeNotifier implements GameManager {
  late final GameRestApi _gameRestApi;
  late final MatchScheduleMapper _scheduleMapper;
  late final ResultsMapper _resultsMapper;
  late final RefereeMapper _refereeMapper;
  late final AgeGroupMapper _ageGroupMapper;

  @override
  late Command<String, void> getScheduleCommand;
  @override
  late Command<String, void> getResultsCommand;

  @override
  late Command<(DateTime originalStart, DateTime actualStart, DateTime end),
      bool> endCurrentGamesCommand;
  @override
  late Command<void, bool> startNextRoundCommand;
  @override
  late Command<void, void> getCurrentRoundCommand;

  @override
  late Command<void, void> getAgeGroupsCommand;

  @override
  late Command<void, void> getAllGamesCommand;
  @override
  late Command<(int, int, int), void> saveGameCommand;

  MatchSchedule _schedule = MatchSchedule('Runde ??');

  @override
  MatchSchedule get schedule => _schedule;
  set schedule(MatchSchedule value) {
    _schedule = value;
    notifyListeners();
  }

  Results _results = Results('Runde ??');
  @override
  Results get results => _results;
  set results(Results value) {
    _results = value;
    notifyListeners();
  }

  List<GameGroup> _gameGroups = [];
  @override
  List<GameGroup> get gameGroups => _gameGroups;
  set gameGroups(List<GameGroup> value) {
    _gameGroups = value;
    notifyListeners();
  }

  List<AgeGroup> _ageGroups = [];
  @override
  List<AgeGroup> get ageGroups => _ageGroups;
  set ageGroups(List<AgeGroup> value) {
    _ageGroups = value;
    notifyListeners();
  }

  List<Game> _games = [];
  @override
  List<Game> get games => _games;
  set games(List<Game> value) {
    _games = value;
    notifyListeners();
  }

  GameManagerImplementation() {
    _gameRestApi = di<GameRestApi>();
    _scheduleMapper = MatchScheduleMapper();
    _resultsMapper = ResultsMapper();
    _refereeMapper = RefereeMapper();
    _ageGroupMapper = AgeGroupMapper();

    getScheduleCommand = Command.createAsyncNoResult(
      (input) async {
        var result = await _gameRestApi.getSchedule(input);
        if (result == null) {
          return; //TODO: error handling
        }

        schedule = _scheduleMapper.map(result);
      },
    );

    getResultsCommand = Command.createAsyncNoResult(
      (input) async {
        var result = await _gameRestApi.getResults(input);
        if (result == null) {
          return; //TODO: error handling
        }

        results = _resultsMapper.map(result);
      },
    );

    endCurrentGamesCommand = Command.createAsync(
      (param) async {
        return await _gameRestApi.endCurrentGames(param.$1, param.$2, param.$3);
      },
      initialValue: false,
    );

    startNextRoundCommand = Command.createAsyncNoParam(
      () async {
        return await _gameRestApi.startNextRound();
      },
      initialValue: false,
    );

    getCurrentRoundCommand = Command.createAsyncNoParamNoResult(() async {
      var result = await _gameRestApi.getCurrentRound();

      gameGroups = result
          .map((gameGroup) => _refereeMapper.mapGameGroup(gameGroup))
          .toList();
    });

    getAgeGroupsCommand = Command.createAsyncNoParamNoResult(
      () async {
        var result = await _gameRestApi.getAllAgeGroups();

        ageGroups = result.map((e) => _ageGroupMapper.map(e)).toList();
      },
    );

    getAllGamesCommand = Command.createAsyncNoParamNoResult(
      () async {
        var result = await _gameRestApi.getAllGames();
        games = result.map((e) => _refereeMapper.mapGame(e)).toList();
      },
    );

    saveGameCommand = Command.createAsyncNoResult(
      (gameResult) async {
        await _gameRestApi.saveGame(
            gameResult.$1, gameResult.$2, gameResult.$3);
      },
    );
  }

  @override
  AgeGroup? getAgeGroupByName(String name) {
    var filtered = ageGroups.where((element) => element.name == name);

    return filtered.isNotEmpty ? filtered.first : null;
  }
}
