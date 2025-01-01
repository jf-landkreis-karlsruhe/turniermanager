import 'package:flutter/material.dart';
import 'package:tournament_manager/src/manager/game_manager.dart';
import 'package:tournament_manager/src/service/game_rest_api.dart';
import 'package:watch_it/watch_it.dart';
import 'src/app.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void setup() {
  // register REST API services
  di.registerSingleton<GameRestApi>(GameRestApiImplementation());

  // register managers
  di.registerSingleton<GameManager>(GameManagerImplementation());
}

void main() async {
  setup();

  usePathUrlStrategy();
  // Run the app.
  runApp(const MainWidget());
}
