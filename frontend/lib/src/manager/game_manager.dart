import 'package:flutter/material.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:tournament_manager/src/service/game_rest_api.dart';
import 'package:watch_it/watch_it.dart';

abstract class GameManager extends ChangeNotifier {
  late Command<String, String> getGameDataCommand;
}

class GameManagerImplementation extends ChangeNotifier implements GameManager {
  late final GameRestApi _gameRestApi;

  @override
  late Command<String, String> getGameDataCommand;

  GameManagerImplementation() {
    _gameRestApi = di<GameRestApi>();

    getGameDataCommand = Command.createAsync(
      (x) async {
        return await _gameRestApi.getGameData();
      },
      initialValue: '',
    );
  }
}
