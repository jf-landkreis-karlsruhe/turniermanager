import 'package:flutter/material.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsManager with ChangeNotifier {
  late Command<void, void> getCanPauseCommand;
  late Command<bool, void> setCanPauseCommand;
  bool get canPause;

  late Command<void, void> getCurrentlyRunningGamesCommand;
  late Command<DateTime?, void> setCurrentlyRunningGamesCommand;
  DateTime? get currentlyRunningGames;

  late Command<void, void> getCurrentTimeInMillisecondsCommand;
  late Command<int?, void> setCurrentTimeInMillisecondsCommand;
  int? get currentTimeInMilliseconds;
}

class SettingsManagerImplementation
    with ChangeNotifier
    implements SettingsManager {
  final String _canPauseKey = 'canPause';
  final String _currentlyRunningGamesKey = 'currentlyRunningGames';
  final String _currentTimeInMinutesKey = 'currentTimeInMinutes';

  @override
  late Command<void, void> getCanPauseCommand;
  @override
  late Command<bool, void> setCanPauseCommand;

  @override
  late Command<void, void> getCurrentlyRunningGamesCommand;
  @override
  late Command<DateTime?, void> setCurrentlyRunningGamesCommand;

  @override
  late Command<void, void> getCurrentTimeInMillisecondsCommand;
  @override
  late Command<int?, void> setCurrentTimeInMillisecondsCommand;

  bool _canPause = false;
  @override
  bool get canPause => _canPause;
  set canPause(bool value) {
    _canPause = value;
    notifyListeners();
  }

  DateTime? _currentlyRunningGames;
  @override
  DateTime? get currentlyRunningGames => _currentlyRunningGames;
  set currentlyRunningGames(DateTime? value) {
    _currentlyRunningGames = value;
    notifyListeners();
  }

  int? _currentTimeInMinutes;
  @override
  int? get currentTimeInMilliseconds => _currentTimeInMinutes;
  set currentTimeInMilliseconds(int? value) {
    _currentTimeInMinutes = value;
    notifyListeners();
  }

  SettingsManagerImplementation() {
    getCanPauseCommand = Command.createAsyncNoParamNoResult(
      () async {
        var prefs = await SharedPreferences.getInstance();
        var result = prefs.getBool(_canPauseKey);

        if (result == null) {
          return;
        }

        canPause = result;
      },
    );

    setCanPauseCommand = Command.createAsyncNoResult(
      (value) async {
        var prefs = await SharedPreferences.getInstance();
        var result = await prefs.setBool(_canPauseKey, value);

        if (!result) {
          return;
        }

        canPause = value;
      },
    );

    getCurrentlyRunningGamesCommand = Command.createAsyncNoParamNoResult(
      () async {
        var prefs = await SharedPreferences.getInstance();
        var result = prefs.getString(_currentlyRunningGamesKey);

        if (result == null) {
          return;
        }

        var converted = DateTime.tryParse(result);

        if (converted == null) {
          return;
        }

        currentlyRunningGames = converted;
      },
    );

    setCurrentlyRunningGamesCommand = Command.createAsyncNoResult(
      (value) async {
        var prefs = await SharedPreferences.getInstance();

        var result = false;
        if (value == null) {
          result = await prefs.remove(_currentlyRunningGamesKey);
        } else {
          result = await prefs.setString(
              _currentlyRunningGamesKey, value.toString());
        }

        if (!result) {
          return;
        }

        currentlyRunningGames = value;
      },
    );

    getCurrentTimeInMillisecondsCommand = Command.createAsyncNoParamNoResult(
      () async {
        var prefs = await SharedPreferences.getInstance();
        var result = prefs.getInt(_currentTimeInMinutesKey);

        if (result == null) {
          return;
        }

        currentTimeInMilliseconds = result;
      },
    );

    setCurrentTimeInMillisecondsCommand = Command.createAsyncNoResult(
      (value) async {
        var prefs = await SharedPreferences.getInstance();

        var result = false;
        if (value == null) {
          result = await prefs.remove(_currentTimeInMinutesKey);
        } else {
          result = await prefs.setInt(_currentTimeInMinutesKey, value);
        }

        if (!result) {
          return;
        }

        currentTimeInMilliseconds = value;
      },
    );
  }
}
