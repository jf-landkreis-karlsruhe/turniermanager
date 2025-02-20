import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:tournament_manager/src/manager/game_manager.dart';
import 'package:watch_it/watch_it.dart';

class RefereeView extends StatelessWidget {
  const RefereeView({super.key});

  static const routeName = '/referee';

  @override
  Widget build(BuildContext context) {
    var gameManager = di<GameManager>();

    return Scaffold(
      appBar: AppBar(
        leading: const Center(
          child: Text(
            'Spielübersicht',
            style: TextStyle(fontSize: 26),
          ),
        ),
        leadingWidth: 200,
        actions: [
          const Text(
            'Runde 1',
            style: TextStyle(fontSize: 26),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () async {
              var result =
                  await gameManager.startNextRoundCommand.executeWithFuture();
              if (result) {
                //TODO: load current round with contained games
              }
            },
            icon: const Icon(Icons.double_arrow),
            tooltip: "Runde beenden / Neue Runde starten",
            iconSize: 40,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            GameView(first: true),
            GameView(first: false),
          ],
        ),
      ),
    );
  }
}

class GameView extends StatefulWidget {
  const GameView({
    super.key,
    required this.first,
  });

  static const double _headerFontSize = 20;
  final bool first;

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  bool currentlyRunning = false;
  bool reset = false;

  Color selectedTextColor = Colors.black;
  Color standardTextColor = Colors.white;
  List<String> games = [
    "1",
    "2",
  ];

  @override
  Widget build(BuildContext context) {
    var gameManager = di<GameManager>();

    List<Widget> rows = [];

    for (var game in games) {
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
                        'Spiel 1',
                        style: TextStyle(
                            fontSize: GameView._headerFontSize,
                            color: currentlyRunning
                                ? selectedTextColor
                                : standardTextColor),
                      ),
                      const SizedBox(width: 10),
                      CountDownView(
                        timeInMinutes: 10,
                        textColor: currentlyRunning
                            ? selectedTextColor
                            : standardTextColor,
                        start: currentlyRunning,
                        refresh: reset,
                      ),
                      const SizedBox(width: 10),
                      if (widget.first)
                        IconButton(
                          onPressed: () async {
                            setState(() {
                              reset = false;
                              currentlyRunning = !currentlyRunning;
                            });

                            var result = await gameManager
                                .startCurrentGamesCommand
                                .executeWithFuture();
                            if (result) {
                              return;
                            }

                            setState(() {
                              currentlyRunning = false;
                              reset = true;
                            });

                            if (!context.mounted) {
                              return;
                            }

                            showError(context,
                                'Spiele konnten nicht gestartet werden');
                          },
                          icon: Icon(currentlyRunning
                              ? Icons.pause
                              : Icons.play_arrow),
                          color: currentlyRunning
                              ? selectedTextColor
                              : standardTextColor,
                          tooltip: "Spiel starten",
                        ),
                      const SizedBox(width: 10),
                      if (widget.first)
                        IconButton(
                          onPressed: () {
                            setState(() {
                              currentlyRunning = false;
                              reset = true;
                            });
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
                        var result = await gameManager.endCurrentGamesCommand
                            .executeWithFuture();

                        setState(() {
                          currentlyRunning = false;
                          reset = true;
                        });

                        if (result) {
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

  final String gameRoundEntry;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          children: [
            Text(
              'Altersgruppe $gameRoundEntry',
              style: TextStyle(color: textColor),
            ),
            const SizedBox(width: 5),
            Text(
              '|',
              style: TextStyle(color: textColor),
            ),
            const SizedBox(width: 5),
            Text(
              'Liga $gameRoundEntry',
              style: TextStyle(color: textColor),
            ),
            const SizedBox(width: 5),
            Text(
              '|',
              style: TextStyle(color: textColor),
            ),
            const SizedBox(width: 5),
            Text(
              'Platz $gameRoundEntry',
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
                'Team A',
                style: TextStyle(color: textColor),
              ),
              const SizedBox(width: 5),
              Text(
                ':',
                style: TextStyle(color: textColor),
              ),
              const SizedBox(width: 5),
              Text(
                'Team B',
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
