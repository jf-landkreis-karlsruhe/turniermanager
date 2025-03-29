import 'package:flutter/material.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsManager with ChangeNotifier {
  late Command<void, void> getCanPauseCommand;
  late Command<bool, void> setCanPauseCommand;
  bool get canPause;
}

class SettingsManagerImplementation
    with ChangeNotifier
    implements SettingsManager {
  @override
  late Command<void, void> getCanPauseCommand;
  @override
  late Command<bool, void> setCanPauseCommand;

  bool _canPause = false;
  @override
  bool get canPause => _canPause;
  set canPause(bool value) {
    _canPause = value;
    notifyListeners();
  }

  SettingsManagerImplementation() {
    getCanPauseCommand = Command.createAsyncNoParamNoResult(
      () async {
        var prefs = await SharedPreferences.getInstance();
        var result = prefs.getBool('canPause');

        if (result == null) {
          return;
        }

        canPause = result;
      },
    );

    setCanPauseCommand = Command.createAsyncNoResult(
      (value) async {
        var prefs = await SharedPreferences.getInstance();
        var result = await prefs.setBool('canPause', value);

        if (!result) {
          return;
        }

        canPause = value;
      },
    );
  }
}
