import 'package:flutter/material.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:tournament_manager/src/mapper/match_schedule_mapper.dart';
import 'package:tournament_manager/src/mapper/results_mapper.dart';
import 'package:tournament_manager/src/model/results/results.dart';
import 'package:tournament_manager/src/model/schedule/match_schedule.dart';
import 'package:tournament_manager/src/service/game_rest_api.dart';
import 'package:watch_it/watch_it.dart';

abstract class GameManager extends ChangeNotifier {
  late Command<String, void> getScheduleCommand;
  late Command<String, void> getResultsCommand;

  late Command<void, bool> startCurrentGamesCommand;
  late Command<void, bool> endCurrentGamesCommand;
  late Command<void, bool> startNextRoundCommand;

  MatchSchedule get schedule;
  Results get results;
}

class GameManagerImplementation extends ChangeNotifier implements GameManager {
  late final GameRestApi _gameRestApi;
  late final MatchScheduleMapper _scheduleMapper;
  late final ResultsMapper _resultsMapper;

  @override
  late Command<String, void> getScheduleCommand;
  @override
  late Command<String, void> getResultsCommand;

  @override
  late Command<void, bool> endCurrentGamesCommand;
  @override
  late Command<void, bool> startCurrentGamesCommand;
  @override
  late Command<void, bool> startNextRoundCommand;

  MatchSchedule _schedule = MatchSchedule(1);

  @override
  MatchSchedule get schedule => _schedule;
  set schedule(MatchSchedule value) {
    _schedule = value;
    notifyListeners();
  }

  Results _results = Results(1);
  @override
  Results get results => _results;
  set results(Results value) {
    _results = value;
    notifyListeners();
  }

  GameManagerImplementation() {
    _gameRestApi = di<GameRestApi>();
    _scheduleMapper = MatchScheduleMapper();
    _resultsMapper = ResultsMapper();

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

    startCurrentGamesCommand = Command.createAsyncNoParam(
      () async {
        var result = await _gameRestApi.startCurrentGames();
        if (result == null) {
          return false; //TODO: error handling
        }

        return result;
      },
      initialValue: false,
    );

    endCurrentGamesCommand = Command.createAsyncNoParam(
      () async {
        var result = await _gameRestApi.endCurrentGames();
        if (result == null) {
          return false; //TODO: error handling
        }

        return result;
      },
      initialValue: false,
    );

    startNextRoundCommand = Command.createAsyncNoParam(
      () async {
        var result = await _gameRestApi.startNextRound();
        if (result == null) {
          return false; //TODO: error handling
        }

        return result;
      },
      initialValue: false,
    );
  }
}
