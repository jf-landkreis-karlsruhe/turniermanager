import 'package:flutter/material.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:tournament_manager/src/mapper/match_schedule_mapper.dart';
import 'package:tournament_manager/src/mapper/referee_mapper.dart';
import 'package:tournament_manager/src/mapper/results_mapper.dart';
import 'package:tournament_manager/src/mapper/tournament_mapper.dart';
import 'package:tournament_manager/src/model/referee/round.dart';
import 'package:tournament_manager/src/model/results/results.dart';
import 'package:tournament_manager/src/model/schedule/match_schedule.dart';
import 'package:tournament_manager/src/model/tournament.dart';
import 'package:tournament_manager/src/service/game_rest_api.dart';
import 'package:watch_it/watch_it.dart';

abstract class GameManager extends ChangeNotifier {
  late Command<String, void> getScheduleCommand;
  late Command<String, void> getResultsCommand;

  late Command<void, bool> startCurrentGamesCommand;
  late Command<void, bool> endCurrentGamesCommand;
  late Command<void, bool> startNextRoundCommand;
  late Command<void, void> getCurrentRoundCommand;

  late Command<int, void> getTournamentCommand;

  MatchSchedule get schedule;
  Results get results;
  Round get currentRound;
  Tournament? get tournament;
}

class GameManagerImplementation extends ChangeNotifier implements GameManager {
  late final GameRestApi _gameRestApi;
  late final MatchScheduleMapper _scheduleMapper;
  late final ResultsMapper _resultsMapper;
  late final RefereeMapper _refereeMapper;
  late final TournamentMapper _tournamentMapper;

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
  @override
  late Command<void, void> getCurrentRoundCommand;

  @override
  late Command<int, void> getTournamentCommand;

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

  Round _currentRound = Round("");
  @override
  Round get currentRound => _currentRound;
  set currentRound(Round value) {
    _currentRound = value;
    notifyListeners();
  }

  Tournament? _tournament;
  @override
  Tournament? get tournament => _tournament;
  set tournament(Tournament? value) {
    _tournament = value;
    notifyListeners();
  }

  GameManagerImplementation() {
    _gameRestApi = di<GameRestApi>();
    _scheduleMapper = MatchScheduleMapper();
    _resultsMapper = ResultsMapper();
    _refereeMapper = RefereeMapper();
    _tournamentMapper = TournamentMapper();

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

    getCurrentRoundCommand = Command.createAsyncNoParamNoResult(() async {
      var result = await _gameRestApi.getCurrentRound();
      if (result == null) {
        return; //TODO: error handling
      }

      currentRound = _refereeMapper.mapRound(result);
    });

    getTournamentCommand = Command.createAsyncNoResult(
      (param) async {
        var result = await _gameRestApi.getTournament(param);
        if (result == null) {
          return; //TODO: error handling
        }

        tournament = _tournamentMapper.map(result);
      },
    );
  }
}
