import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:tournament_manager/src/Constants.dart';
import 'package:tournament_manager/src/helper/error_helper.dart';
import 'package:tournament_manager/src/manager/game_manager.dart';
import 'package:tournament_manager/src/model/referee/game.dart';
import 'package:tournament_manager/src/model/referee/game_group.dart';
import 'package:tournament_manager/src/service/sound_player_service.dart';
import 'package:watch_it/watch_it.dart';
import 'package:intl/intl.dart';

class RefereeView extends StatelessWidget with WatchItMixin {
  const RefereeView({super.key});

  static const routeName = '/referee';

  @override
  Widget build(BuildContext context) {
    var gameManager = di<GameManager>();
    var gameGroups =
        watchPropertyValue((GameManager manager) => manager.gameGroups);

    return Scaffold(
      appBar: AppBar(
        leading: const Center(
          child: Text(
            'Spielübersicht',
            style: Constants.largeHeaderTextStyle,
          ),
        ),
        leadingWidth: 200,
        actions: [
          const SizedBox(
            width: 200,
            child: TextField(
              //TODO: use value from textfield in call to start next round
              decoration: InputDecoration(
                  label: Text(
                'max. # Teams / Runde',
                style: Constants.standardTextStyle,
              )),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () async {
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
                              .executeWithFuture();
                          if (result) {
                            gameManager.getCurrentRoundCommand();
                          }

                          if (!dialogContext.mounted) {
                            return;
                          }

                          GoRouter.of(dialogContext).pop();
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
              first: index == 0,
              gameGroup: gameGroup,
            );
          },
          itemCount: gameGroups.length,
        ),
      ),
    );
  }
}

class GameView extends StatefulWidget {
  const GameView({
    super.key,
    required this.first,
    required this.gameGroup,
  });

  final bool first;
  final GameGroup gameGroup;

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

  @override
  Widget build(BuildContext context) {
    var gameManager = di<GameManager>();

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
                          onPressed: () async {
                            if (!currentlyRunning &&
                                currentGamesActualStart == null) {
                              currentGamesActualStart = DateTime.now();
                            }

                            setState(() {
                              reset = false;
                              currentlyRunning = !currentlyRunning;
                            });
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
                        onHalftime: () {
                          setState(() {
                            currentlyRunning = false;
                          });
                        },
                      ),
                      const SizedBox(width: 5),
                      if (widget.first)
                        IconButton(
                          onPressed: () {
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
                  if (widget.first)
                    IconButton(
                      onPressed: () async {
                        if (currentGamesActualStart == null) {
                          showError(context,
                              'Spiele wurden nicht gestartet und konnten daher nicht beendet werden');
                          return;
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
  });

  final int timeInMinutes;
  final Color textColor;
  final bool start;
  final bool refresh;
  final void Function()? onEnded;
  final void Function()? onHalftime;

  @override
  State<CountDownView> createState() => _CountDownViewState();
}

class _CountDownViewState extends State<CountDownView> {
  String currentTime = '';
  bool onEndedCalled = false;
  bool halfTimeSoundPlayed = false;

  final soundPlayerService = di<SoundPlayerService>();

  late final StopWatchTimer _stopWatchTimer;

  @override
  void initState() {
    currentTime = '00:${widget.timeInMinutes}:00.00';
    var totalTimeInMilliSeconds =
        StopWatchTimer.getMilliSecFromMinute(widget.timeInMinutes);

    _stopWatchTimer = StopWatchTimer(
      mode: StopWatchMode.countDown,
      presetMillisecond: totalTimeInMilliSeconds,
      onChange: (value) {
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
      _stopWatchTimer.onResetTimer();
      setState(() {
        onEndedCalled = false;
        halfTimeSoundPlayed = false;
      });
    } else {
      if (widget.start) {
        _stopWatchTimer.onStartTimer();
      } else {
        _stopWatchTimer.onStopTimer();
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
