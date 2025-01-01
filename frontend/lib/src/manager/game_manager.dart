import 'package:flutter/material.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:tournament_manager/src/service/game_rest_api.dart';
import 'package:watch_it/watch_it.dart';

abstract class GameManager extends ChangeNotifier {
  late Command<(String ageGroup, String league), void> getGameDataCommand;
}

class GameManagerImplementation extends ChangeNotifier implements GameManager {
  late final GameRestApi _gameRestApi;

  @override
  late Command<(String ageGroup, String league), void> getGameDataCommand;

  GameManagerImplementation() {
    _gameRestApi = di<GameRestApi>();

    getGameDataCommand = Command.createAsyncNoResult(
      (input) async {
        await _gameRestApi.getSchedule(
            input.$1, input.$2); // TODO: map and save result
      },
    );
  }
}
