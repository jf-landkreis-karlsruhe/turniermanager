import 'package:flutter/material.dart';
import 'package:tournament_manager/src/manager/game_manager.dart';
import 'package:tournament_manager/src/service/config_service.dart';
import 'package:tournament_manager/src/service/game_rest_api.dart';
import 'package:tournament_manager/src/service/sound_player_service.dart';
import 'package:watch_it/watch_it.dart';
import 'src/app.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

Future setup() async {
  // register services
  var configService = ConfigServiceImplementation();
  di.registerSingleton<ConfigService>(configService);
  di.registerSingleton<SoundPlayerService>(SoundPlayerServiceImplementation());

  // register REST API services
  di.registerSingletonAsync<GameRestApi>(
    () async {
      var backend = await configService.getBackendUrl();

      if (backend.toLowerCase().trim() == 'local') {
        return GameTestRestApi(); // this is for local tests
      } else {
        var url = Uri.http(backend);
        return GameRestApiImplementation(
            url.toString()); // this is for the real world
      }
    },
  );

  // register managers
  di.registerSingleton<GameManager>(GameManagerImplementation());
}

void main() async {
  usePathUrlStrategy();
  // Run the app.
  runApp(MainWidget());
}
