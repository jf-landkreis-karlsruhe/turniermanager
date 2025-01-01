import 'package:flutter/material.dart';
import 'package:tournament_manager/src/manager/game_manager.dart';
import 'package:tournament_manager/src/model/league.dart';
import 'package:watch_it/watch_it.dart';

class ScheduleView extends StatelessWidget with WatchItMixin {
  const ScheduleView(
    this.ageGroup, {
    super.key,
  });

  final String ageGroup;

  static const routeName = '/schedule';
  static const ageGroupQueryParam = 'ageGroup';

  @override
  Widget build(BuildContext context) {
    var schedule =
        watchPropertyValue((GameManager manager) => manager.schedule);

    return Column(
      children: [
        SizedBox(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Spielplan'),
              Row(
                children: [
                  Text('Altersklasse $ageGroup'),
                  const SizedBox(width: 5),
                  const Text('|'),
                  const SizedBox(width: 5),
                  Text('Spielrunde ${schedule.matchRound}'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: schedule.leagueSchedules.length,
            itemBuilder: (context, index) {
              var entry = schedule.leagueSchedules[index];
              return LeagueView(league: entry);
            },
          ),
        )
      ],
    );
  }
}

class LeagueView extends StatelessWidget {
  const LeagueView({
    super.key,
    required this.league,
  });

  final League league;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          SizedBox(
            height: 20,
            child: Row(
              children: [
                Text('Liga ${league.leagueNo}'),
                const SizedBox(width: 10),
                const Icon(Icons.gamepad),
              ],
            ),
          ),
          Expanded(
            child: Text('Test'),
          ),
        ],
      ),
    );
  }
}
