import 'package:flutter/material.dart';

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
      body: const Padding(
        padding: EdgeInsets.all(10),
        child: Column(
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

  @override
  Widget build(BuildContext context) {
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
                children: [
                  const Text(
                    'Spielrunde 1',
                    style: TextStyle(fontSize: GameRoundView._headerFontSize),
                  ),
                  const SizedBox(width: 10),
                  Text('10:00'),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        currentlyRunning = !currentlyRunning;
                      });
                    },
                    icon:
                        Icon(currentlyRunning ? Icons.stop : Icons.play_arrow),
                    color: currentlyRunning ? Colors.black : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
