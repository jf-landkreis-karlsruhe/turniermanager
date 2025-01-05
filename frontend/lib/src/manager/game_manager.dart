import 'package:flutter/material.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:tournament_manager/src/mapper/match_schedule_mapper.dart';
import 'package:tournament_manager/src/model/schedule/match_schedule.dart';
import 'package:tournament_manager/src/service/game_rest_api.dart';
import 'package:watch_it/watch_it.dart';

abstract class GameManager extends ChangeNotifier {
  late Command<String, void> getGameDataCommand;

  MatchSchedule get schedule;
}

class GameManagerImplementation extends ChangeNotifier implements GameManager {
  late final GameRestApi _gameRestApi;
  late final MatchScheduleMapper _scheduleMapper;

  @override
  late Command<String, void> getGameDataCommand;

  MatchSchedule _schedule = MatchSchedule(1);
  @override
  MatchSchedule get schedule => _schedule;
  set schedule(MatchSchedule value) {
    _schedule = value;
    notifyListeners();
  }

  GameManagerImplementation() {
    _gameRestApi = di<GameRestApi>();
    _scheduleMapper = MatchScheduleMapper();

    getGameDataCommand = Command.createAsyncNoResult(
      (input) async {
        var result = await _gameRestApi.getSchedule(input);
        if (result == null) {
          return; //TODO: error handling
        }

        schedule = _scheduleMapper.map(result);
      },
    );
  }
}
