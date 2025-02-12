import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
            GameRoundView(),
            GameRoundView(),
          ],
        ),
      ),
    );
  }
}

class GameRoundView extends StatefulWidget {
  const GameRoundView({super.key});

  static const double _headerFontSize = 20;

  @override
  State<GameRoundView> createState() => _GameRoundViewState();
}

class _GameRoundViewState extends State<GameRoundView> {
  bool currentlyRunning = false;

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
                    Text(
                      '10:00',
                      style: TextStyle(
                          color: currentlyRunning
                              ? selectedTextColor
                              : standardTextColor),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          currentlyRunning = !currentlyRunning;
                        });
                      },
                      icon: Icon(
                          currentlyRunning ? Icons.stop : Icons.play_arrow),
                      color: currentlyRunning
                          ? selectedTextColor
                          : standardTextColor,
                    ),
                    IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.start,
                          color: currentlyRunning
                              ? selectedTextColor
                              : standardTextColor,
                        ))
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
