import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class RefereeView extends StatelessWidget {
  const RefereeView({super.key});

  static const routeName = '/referee';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Center(
          child: Text(
            'Spielübersicht',
            style: TextStyle(fontSize: 26),
          ),
        ),
        leadingWidth: 200,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            GameRoundView(first: true),
            GameRoundView(first: false),
          ],
        ),
      ),
    );
  }
}

class GameRoundView extends StatefulWidget {
  const GameRoundView({
    super.key,
    required this.first,
  });

  static const double _headerFontSize = 20;
  final bool first;

  @override
  State<GameRoundView> createState() => _GameRoundViewState();
}

class _GameRoundViewState extends State<GameRoundView> {
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
    return Card(
      color: currentlyRunning ? Colors.blue : null,
      child: SizedBox(
        height: 315,
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
                          'Spielrunde 1',
                          style: TextStyle(
                              fontSize: GameRoundView._headerFontSize,
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
                            onPressed: () {
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
                            tooltip: "Runde starten",
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
                            tooltip: "Runde zurücksetzen",
                          ),
                      ],
                    ),
                    if (widget.first)
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.start,
                          color: currentlyRunning
                              ? selectedTextColor
                              : standardTextColor,
                        ),
                        tooltip: "Runde beenden",
                      )
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    var element = games[index];
                    return GameRoundEntryView(
                      gameRoundEntry: element,
                      textColor: currentlyRunning
                          ? selectedTextColor
                          : standardTextColor,
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: games.length,
                ),
              ),
            ),
          ],
        ),
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

class GameRoundEntryView extends StatelessWidget {
  const GameRoundEntryView({
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
        SizedBox(
          width: 150,
          child: Text(
            'Platz $gameRoundEntry',
            style: TextStyle(color: textColor),
          ),
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
