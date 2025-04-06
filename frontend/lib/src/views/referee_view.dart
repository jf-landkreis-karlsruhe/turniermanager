import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:tournament_manager/src/constants.dart';
import 'package:tournament_manager/src/helper/error_helper.dart';
import 'package:tournament_manager/src/manager/game_manager.dart';
import 'package:tournament_manager/src/manager/settings_manager.dart';
import 'package:tournament_manager/src/model/referee/game.dart';
import 'package:tournament_manager/src/model/referee/game_group.dart';
import 'package:tournament_manager/src/service/sound_player_service.dart';
import 'package:watch_it/watch_it.dart';
import 'package:intl/intl.dart';

class RefereeView extends StatefulWidget with WatchItStatefulWidgetMixin {
  RefereeView({super.key});

  static const routeName = '/referee';

  @override
  State<RefereeView> createState() => _RefereeViewState();
}

class _RefereeViewState extends State<RefereeView> {
  final Map<String, int> ageGroupIdToMaxTeams = {};
  var barrierDissmissed = false;

  @override
  Widget build(BuildContext context) {
    var gameManager = di<GameManager>();
    var settingsManager = di<SettingsManager>();

    var gameGroups =
        watchPropertyValue((GameManager manager) => manager.gameGroups);
    var ageGroups =
        watchPropertyValue((GameManager manager) => manager.ageGroups);

    bool canPauseGames =
        watchPropertyValue((SettingsManager manager) => manager.canPause);
    var currentlyRunningGames = watchPropertyValue(
        (SettingsManager manager) => manager.currentlyRunningGames);

    for (var ageGroup in ageGroups) {
      ageGroupIdToMaxTeams.update(
        ageGroup.id,
        (value) => 6,
        ifAbsent: () => 6,
      );
    }

    var mainContent = Scaffold(
      appBar: AppBar(
        leading: const Center(
          child: Text(
            'Spielübersicht',
            style: Constants.largeHeaderTextStyle,
          ),
        ),
        leadingWidth: 200,
        actions: [
          Tooltip(
            message: 'Umschalten: Spiele können pausiert werden',
            child: Switch(
              value: canPauseGames,
              onChanged: (value) {
                settingsManager.setCanPauseCommand(!canPauseGames);
              },
              activeColor: Colors.blue,
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    title: const Text('Max. Anzahl Teams / Runde'),
                    content: SizedBox(
                      height: MediaQuery.of(context).size.height / 2,
                      width: 300,
                      child: ListView.separated(
                        itemBuilder: (_, index) {
                          var ageGroup = ageGroups[index];

                          return TextField(
                            controller: TextEditingController(
                              text:
                                  Constants.maxNumberOfTeamsDefault.toString(),
                            ),
                            decoration: InputDecoration(
                              label: Text(ageGroup.name),
                            ),
                            onChanged: (userInput) {
                              var result = int.tryParse(userInput);
                              if (result == null) {
                                return;
                              }

                              ageGroupIdToMaxTeams.update(
                                ageGroup.id,
                                (value) => result,
                                ifAbsent: () => 6,
                              );
                            },
                          );
                        },
                        separatorBuilder: (_, index) {
                          return const SizedBox(height: 10);
                        },
                        itemCount: ageGroups.length,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => GoRouter.of(dialogContext).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.groups),
            tooltip: "Max # Teams / Runde ändern",
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () async {
              if (currentlyRunningGames != null) {
                showError(context,
                    'Runde konnte nicht gewechselt werden, es laufen noch Spiele!');
                return;
              }

              showDialog(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    icon: const Icon(Icons.warning),
                    iconColor: Colors.yellow,
                    title: const Text('Wechsel zur nächsten Runde'),
                    content: const SizedBox(
                      height: 100,
                      child: Center(
                        child: Text(
                          'Soll diese Runde wirklich beendet werden?\nDieser Schritt kann nicht rückgängig gemacht werden!',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () async {
                          var result = await gameManager.startNextRoundCommand
                              .executeWithFuture(ageGroupIdToMaxTeams);
                          if (result) {
                            gameManager.getCurrentRoundCommand();
                            settingsManager
                                .setCurrentlyRunningGamesCommand(null);
                            settingsManager
                                .setCurrentTimeInMillisecondsCommand(null);
                          }

                          if (!dialogContext.mounted) {
                            return;
                          }

                          GoRouter.of(dialogContext).pop();

                          if (!result) {
                            showError(context,
                                'Nächste Runde konnte nicht gestartet werden!');
                          }
                        },
                        child: const Text('OK'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          GoRouter.of(dialogContext).pop();
                        },
                        child: const Text('Abbrechen'),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Row(
              children: [
                Icon(
                  Icons.double_arrow,
                  color: Colors.white,
                  size: Constants.headerIonSize,
                ),
                SizedBox(width: 5),
                Text(
                  'Nächste Runde',
                  style: Constants.largeHeaderTextStyle,
                ),
                SizedBox(width: 5),
                Icon(
                  Icons.double_arrow,
                  color: Colors.white,
                  size: Constants.headerIonSize,
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView.builder(
          itemBuilder: (context, index) {
            var gameGroup = gameGroups[index];
            return GameView(
              key: ValueKey('${index}_${gameGroup.startTime.toString()}'),
              first: index == 0,
              gameGroup: gameGroup,
              canPauseGames: canPauseGames,
              onStart: () {
                setState(
                  () {
                    barrierDissmissed = true;
                  },
                );
              },
            );
          },
          itemCount: gameGroups.length,
        ),
      ),
    );

    List<Widget> unmuteBarrier = [
      ModalBarrier(
        color: Colors.white.withOpacity(0.3),
        onDismiss: () {
          setState(() {
            barrierDissmissed = true;
          });
        },
      ),
      Center(
        child: IconButton(
          onPressed: () {
            setState(() {
              barrierDissmissed = true;
            });
          },
          icon: const Icon(
            Icons.volume_up,
            size: 100,
          ),
        ),
      )
    ];

    return Stack(
      children: [
        mainContent,
        if (currentlyRunningGames != null && !barrierDissmissed)
          ...unmuteBarrier,
      ],
    );
  }
}

class GameView extends StatefulWidget with WatchItStatefulWidgetMixin {
  const GameView({
    super.key,
    required this.first,
    required this.gameGroup,
    this.canPauseGames = false,
    this.onStart,
  });

  final bool first;
  final bool canPauseGames;
  final GameGroup gameGroup;
  final void Function()? onStart;

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  bool currentlyRunning = false;
  bool reset = false;
  DateTime? currentGamesActualStart;

  Color selectedTextColor = Colors.black;
  Color standardTextColor = Colors.white;

  final soundPlayerService = di<SoundPlayerService>();
  var settingsManager = di<SettingsManager>();

  bool gameTimeEnded = false;

  @override
  Widget build(BuildContext context) {
    var gameManager = di<GameManager>();
    settingsManager.getCurrentTimeInMillisecondsCommand();

    void startOrPauseGames() {
      if (!currentlyRunning && currentGamesActualStart == null) {
        currentGamesActualStart = DateTime.now();
        settingsManager
            .setCurrentlyRunningGamesCommand(widget.gameGroup.startTime);
      }

      if (!widget.canPauseGames) {
        setState(() {
          reset = false;
          currentlyRunning = true;
        });

        return;
      }

      setState(() {
        reset = false;
        currentlyRunning = !currentlyRunning;
      });
    }

    var currentlyRunningGames = watchPropertyValue(
        (SettingsManager manager) => manager.currentlyRunningGames);

    if (currentlyRunningGames != null &&
        currentlyRunningGames == widget.gameGroup.startTime &&
        !currentlyRunning &&
        !reset) {
      settingsManager.getCurrentTimeInMillisecondsCommand();
      startOrPauseGames();
    }

    List<Widget> rows = [];

    for (var game in widget.gameGroup.games) {
      rows.add(
        GameEntryView(
          gameRoundEntry: game,
          textColor: currentlyRunning ? selectedTextColor : standardTextColor,
        ),
      );

      rows.add(const Divider());
    }

    rows.removeLast();

    var color = currentlyRunning ? selectedTextColor : standardTextColor;
    var headerTextStyle = Constants.mediumHeaderTextStyle.copyWith(
      color: color,
    );

    return Card(
      color: currentlyRunning ? Colors.blue : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Startzeit: ${DateFormat.Hm().format(widget.gameGroup.startTime)} Uhr',
                        style: headerTextStyle,
                      ),
                      const SizedBox(width: 10),
                      if (widget.first)
                        IconButton(
                          onPressed: !widget.canPauseGames
                              ? currentlyRunning
                                  ? null
                                  : () {
                                      startOrPauseGames();
                                      if (widget.onStart != null) {
                                        widget.onStart!();
                                      }
                                    }
                              : () {
                                  startOrPauseGames();
                                  if (widget.onStart != null) {
                                    widget.onStart!();
                                  }
                                },
                          icon: Icon(currentlyRunning
                              ? Icons.pause
                              : Icons.play_arrow),
                          color: color,
                          tooltip: "Spiel starten",
                        ),
                      const SizedBox(width: 5),
                      CountDownView(
                        timeInMinutes: widget.gameGroup.gameDurationInMinutes,
                        textColor: color,
                        start: currentlyRunning,
                        refresh: reset,
                        startTimeInMilliSeconds: currentlyRunningGames == null
                            ? null
                            : settingsManager.currentTimeInMilliseconds,
                        onHalftime: () {
                          if (!widget.canPauseGames) {
                            return;
                          }

                          setState(() {
                            currentlyRunning = false;
                          });
                        },
                        onEnded: () {
                          setState(() {
                            gameTimeEnded = true;
                          });
                        },
                      ),
                      const SizedBox(width: 5),
                      if (widget.first)
                        IconButton(
                          onPressed: () {
                            settingsManager
                                .setCurrentlyRunningGamesCommand(null);
                            settingsManager
                                .setCurrentTimeInMillisecondsCommand(null);

                            setState(() {
                              currentlyRunning = false;
                              reset = true;
                            });

                            currentGamesActualStart = null;
                          },
                          icon: const Icon(Icons.refresh),
                          color: color,
                          tooltip: "Spiel zurücksetzen",
                        ),
                    ],
                  ),
                  if (!widget.first)
                    SizedBox(
                      width: 100,
                      child: Tooltip(
                        message: 'Pause einfügen (vorher)',
                        child: TextField(
                          decoration: const InputDecoration(
                            suffixIcon: Icon(Icons.more_time),
                          ),
                          onSubmitted: (value) async {
                            var parsed = int.tryParse(value);
                            if (parsed == null) {
                              showError(context, 'Falsches Zahlenformat!');
                              return;
                            }

                            var result = await gameManager.addBreakCommand
                                .executeWithFuture(
                              (
                                widget.gameGroup.startTime.subtract(
                                  const Duration(
                                    minutes: 1,
                                  ), //subtract one minute to start the break before these games
                                ),
                                parsed,
                              ),
                            );

                            if (result) {
                              gameManager.getCurrentRoundCommand();
                              return;
                            }

                            if (!context.mounted) {
                              return;
                            }

                            showError(context,
                                'Pause konnte nicht eingefügt werden!');
                          },
                        ),
                      ),
                    ),
                  if (widget.first)
                    IconButton(
                      onPressed: () async {
                        if (currentGamesActualStart == null) {
                          showError(context,
                              'Spiele wurden nicht gestartet und konnten daher nicht beendet werden');
                          return;
                        }

                        if (!gameTimeEnded) {
                          bool? dialogResult = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) {
                              return AlertDialog(
                                icon: const Icon(Icons.warning),
                                iconColor: Colors.yellow,
                                title: const Text('Wechsel zur nächsten Runde'),
                                content: const SizedBox(
                                  height: 100,
                                  child: Center(
                                    child: Text(
                                      'Spielzeit ist noch nicht abgelaufen. Spiele wirklich beenden?',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      GoRouter.of(dialogContext).pop(true);
                                    },
                                    child: const Text('OK'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      GoRouter.of(dialogContext).pop(false);
                                    },
                                    child: const Text('Abbrechen'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (dialogResult != null && !dialogResult) {
                            return;
                          }
                        }

                        var result = await gameManager.endCurrentGamesCommand
                            .executeWithFuture(
                          (
                            widget.gameGroup.startTime,
                            currentGamesActualStart!,
                            DateTime.now(),
                          ),
                        );

                        setState(() {
                          currentlyRunning = false;
                          reset = true;
                          currentGamesActualStart = null;
                        });

                        if (result) {
                          settingsManager.setCurrentlyRunningGamesCommand(null);
                          settingsManager
                              .setCurrentTimeInMillisecondsCommand(null);
                          gameManager.getCurrentRoundCommand();
                          return;
                        }

                        if (!context.mounted) {
                          return;
                        }

                        showError(
                            context, 'Spiele konnten nicht beendet werden');
                      },
                      icon: Icon(
                        Icons.start,
                        color: color,
                      ),
                      tooltip: "Spiel beenden",
                    )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
              bottom: 10,
            ),
            child: Column(
              children: rows.toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class CountDownView extends StatefulWidget {
  const CountDownView({
    super.key,
    required this.timeInMinutes,
    required this.textColor,
    required this.start,
    required this.refresh,
    this.onEnded,
    this.onHalftime,
    this.startTimeInMilliSeconds,
  });

  final int timeInMinutes;
  final Color textColor;
  final bool start;
  final bool refresh;
  final void Function()? onEnded;
  final void Function()? onHalftime;

  final int? startTimeInMilliSeconds;

  @override
  State<CountDownView> createState() => _CountDownViewState();
}

class _CountDownViewState extends State<CountDownView> {
  String currentTime = '';
  bool onEndedCalled = false;
  bool halfTimeSoundPlayed = false;

  final soundPlayerService = di<SoundPlayerService>();
  var settingsManager = di<SettingsManager>();

  late final StopWatchTimer _stopWatchTimer;

  @override
  void initState() {
    currentTime =
        '00:${widget.timeInMinutes < 10 ? '0' : ''}${widget.timeInMinutes}:00.00';
    var totalTimeInMilliSeconds =
        StopWatchTimer.getMilliSecFromMinute(widget.timeInMinutes);

    _stopWatchTimer = StopWatchTimer(
      mode: StopWatchMode.countDown,
      presetMillisecond: totalTimeInMilliSeconds,
      onChange: (value) {
        settingsManager.setCurrentTimeInMillisecondsCommand(value);
        final displayTime = StopWatchTimer.getDisplayTime(value);

        setState(() {
          currentTime = displayTime;
        });

        if ((value <= totalTimeInMilliSeconds / 2) && !halfTimeSoundPlayed) {
          soundPlayerService.playSound(Sounds.horn);
          setState(() {
            halfTimeSoundPlayed = true;
          });

          if (widget.onHalftime == null) {
            return;
          }

          widget.onHalftime!();
        }

        // end music is 32 seconds, where 3 seconds are the horn that signals the end
        if (value <= (29 * 1000) && !onEndedCalled) {
          soundPlayerService.playSound(Sounds.endMusic);
          setState(() {
            onEndedCalled = true;
          });
        }
      },
      onEnded: () {
        settingsManager.setCurrentlyRunningGamesCommand(null);
        settingsManager.setCurrentTimeInMillisecondsCommand(null);

        if (widget.onEnded != null) {
          widget.onEnded!();
        }

        if (onEndedCalled) {
          return;
        }

        // in case the end music was not yet played (maybe because of too short duration), play horn at the end
        soundPlayerService.playSound(Sounds.horn);

        setState(() {
          onEndedCalled = true;
        });
      },
    );
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.refresh) {
      if (_stopWatchTimer.isRunning) {
        _stopWatchTimer.onResetTimer();

        _stopWatchTimer.clearPresetTime();
      }

      setState(() {
        onEndedCalled = false;
        halfTimeSoundPlayed = false;
      });
    } else {
      if (widget.start) {
        if (!_stopWatchTimer.isRunning) {
          if (widget.startTimeInMilliSeconds != null) {
            _stopWatchTimer.setPresetTime(
              mSec: widget.startTimeInMilliSeconds!,
              add: false,
            );
          }
          _stopWatchTimer.onStartTimer();
        }
      } else {
        if (_stopWatchTimer.isRunning) {
          _stopWatchTimer.onStopTimer();
        }
      }
    }

    return Text(
      currentTime,
      style: Constants.mediumHeaderTextStyle.copyWith(color: widget.textColor),
    );
  }
}

class GameEntryView extends StatelessWidget {
  const GameEntryView({
    super.key,
    required this.gameRoundEntry,
    required this.textColor,
  });

  final Game gameRoundEntry;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    var textStyle = Constants.standardTextStyle.copyWith(color: textColor);

    return Row(
      children: [
        Row(
          children: [
            Text(
              gameRoundEntry.ageGroupName,
              style: textStyle,
            ),
            const SizedBox(width: 5),
            Text(
              '|',
              style: textStyle,
            ),
            const SizedBox(width: 5),
            Text(
              gameRoundEntry.leagueName,
              style: textStyle,
            ),
            const SizedBox(width: 5),
            Text(
              '|',
              style: textStyle,
            ),
            const SizedBox(width: 5),
            Text(
              gameRoundEntry.pitch.name,
              style: textStyle,
            ),
          ],
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                gameRoundEntry.teamA.name,
                style: textStyle,
              ),
              const SizedBox(width: 5),
              Text(
                ':',
                style: textStyle,
              ),
              const SizedBox(width: 5),
              Text(
                gameRoundEntry.teamB.name,
                style: textStyle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
