import 'package:tournament_manager/src/service/game_rest_api.dart';
import 'package:watch_it/watch_it.dart';

abstract class GameManager {}

class GameManagerImplementation implements GameManager {
  late final GameRestApi _gameRestApi;

  GameManagerImplementation() {
    _gameRestApi = di<GameRestApi>();
  }
}
