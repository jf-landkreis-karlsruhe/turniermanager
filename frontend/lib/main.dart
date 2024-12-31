import 'package:flutter/material.dart';
import 'package:tournament_manager/src/manager/game_manager.dart';
import 'package:tournament_manager/src/service/game_rest_api.dart';
import 'package:watch_it/watch_it.dart';
import 'src/app.dart';

void setup() {
  // register REST API services
  di.registerSingleton<GameRestApi>(GameRestApiImplementation());

  // register managers
  di.registerSingleton<GameManager>(GameManagerImplementation());
}

void main() async {
  setup();
  // Run the app.
  runApp(const MainWidget());
}
