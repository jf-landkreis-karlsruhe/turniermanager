import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:tournament_manager/src/manager/game_manager.dart';
import 'package:tournament_manager/src/model/referee/game.dart';
import 'package:tournament_manager/src/model/referee/game_group.dart';
import 'package:watch_it/watch_it.dart';
import 'package:intl/intl.dart';

class RefereeView extends StatelessWidget with WatchItMixin {
  const RefereeView({super.key});

  static const routeName = '/referee';

  static const _headerTextSize = 26.0;

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
            style: TextStyle(fontSize: _headerTextSize),
          ),
        ),
        leadingWidth: 200,
        actions: [
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
                  size: 40,
                ),
                SizedBox(width: 5),
                Text(
                  'Nächste Runde',
                  style: TextStyle(
                    fontSize: _headerTextSize,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 5),
                Icon(
                  Icons.double_arrow,
                  color: Colors.white,
                  size: 40,
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

  static const double _headerFontSize = 20;
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

  final player = AudioPlayer();

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
                        style: TextStyle(
                            fontSize: GameView._headerFontSize,
                            color: currentlyRunning
                                ? selectedTextColor
                                : standardTextColor),
                      ),
                      const SizedBox(width: 10),
                      if (widget.first)
                        IconButton(
                          onPressed: () async {
                            if (!currentlyRunning &&
                                currentGamesActualStart == null) {
                              currentGamesActualStart = DateTime.now();
                              await player
                                  .play(AssetSource('sounds/gong_sound.wav'));
                            }

                            setState(() {
                              reset = false;
                              currentlyRunning = !currentlyRunning;
                            });
                          },
                          icon: Icon(currentlyRunning
                              ? Icons.pause
                              : Icons.play_arrow),
                          color: currentlyRunning
                              ? selectedTextColor
                              : standardTextColor,
                          tooltip: "Spiel starten",
                        ),
                      const SizedBox(width: 5),
                      CountDownView(
                        timeInMinutes: widget.gameGroup.gameDurationInMinutes,
                        textColor: currentlyRunning
                            ? selectedTextColor
                            : standardTextColor,
                        start: currentlyRunning,
                        refresh: reset,
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
                          color: currentlyRunning
                              ? selectedTextColor
                              : standardTextColor,
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
                        color: currentlyRunning
                            ? selectedTextColor
                            : standardTextColor,
                      ),
                      tooltip: "Spiel beenden",
                    )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
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
  });

  final int timeInMinutes;
  final Color textColor;
  final bool start;
  final bool refresh;
  final void Function()? onEnded;

  @override
  State<CountDownView> createState() => _CountDownViewState();
}

class _CountDownViewState extends State<CountDownView> {
  String currentTime = '';

  late final StopWatchTimer _stopWatchTimer;

  @override
  void initState() {
    currentTime = '00:${widget.timeInMinutes}:00.00';

    _stopWatchTimer = StopWatchTimer(
      mode: StopWatchMode.countDown,
      presetMillisecond:
          StopWatchTimer.getMilliSecFromMinute(widget.timeInMinutes),
      onChange: (value) {
        final displayTime = StopWatchTimer.getDisplayTime(value);
        setState(() {
          currentTime = displayTime;
        });
      },
      onEnded: widget.onEnded,
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
    } else {
      if (widget.start) {
        _stopWatchTimer.onStartTimer();
      } else {
        _stopWatchTimer.onStopTimer();
      }
    }

    return Text(
      currentTime,
      style: TextStyle(color: widget.textColor),
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
    return Row(
      children: [
        Row(
          children: [
            Text(
              gameRoundEntry.ageGroupName,
              style: TextStyle(color: textColor),
            ),
            const SizedBox(width: 5),
            Text(
              '|',
              style: TextStyle(color: textColor),
            ),
            const SizedBox(width: 5),
            Text(
              gameRoundEntry.leagueName,
              style: TextStyle(color: textColor),
            ),
            const SizedBox(width: 5),
            Text(
              '|',
              style: TextStyle(color: textColor),
            ),
            const SizedBox(width: 5),
            Text(
              gameRoundEntry.pitch.name,
              style: TextStyle(color: textColor),
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
                style: TextStyle(color: textColor),
              ),
              const SizedBox(width: 5),
              Text(
                ':',
                style: TextStyle(color: textColor),
              ),
              const SizedBox(width: 5),
              Text(
                gameRoundEntry.teamB.name,
                style: TextStyle(color: textColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void showError(context, String errorText) {
  if (!context.mounted) {
    return;
  }

  var scaffoldMessenger = ScaffoldMessenger.maybeOf(context);

  scaffoldMessenger?.showSnackBar(
    SnackBar(
      content: Center(
        child: Text(
          'Fehler: $errorText',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
