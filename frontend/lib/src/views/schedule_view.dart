import 'package:flutter/material.dart';
import 'package:tournament_manager/src/manager/game_manager.dart';
import 'package:tournament_manager/src/model/league.dart';
import 'package:tournament_manager/src/model/match_schedule_entry.dart';
import 'package:watch_it/watch_it.dart';

class ScheduleView extends StatelessWidget with WatchItMixin {
  const ScheduleView(
    this.ageGroup, {
    super.key,
  });

  final String ageGroup;

  static const routeName = '/schedule';
  static const ageGroupQueryParam = 'ageGroup';

  static const double _headerFontSize = 26;

  @override
  Widget build(BuildContext context) {
    var schedule =
        watchPropertyValue((GameManager manager) => manager.schedule);

    return Scaffold(
      appBar: AppBar(
        leading: const Center(
          child: Text(
            'Spielplan',
            style: TextStyle(fontSize: _headerFontSize),
          ),
        ),
        leadingWidth: 150,
        actions: [
          Text(
            'Altersklasse $ageGroup',
            style: const TextStyle(fontSize: _headerFontSize),
          ),
          const SizedBox(width: 5),
          const Text(
            '|',
            style: TextStyle(fontSize: _headerFontSize),
          ),
          const SizedBox(width: 5),
          Text(
            'Spielrunde ${schedule.matchRound}',
            style: const TextStyle(fontSize: _headerFontSize),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: schedule.leagueSchedules.length,
          itemBuilder: (context, index) {
            var entry = schedule.leagueSchedules[index];
            return LeagueView(league: entry);
          },
        ),
      ),
    );
  }
}

class LeagueView extends StatelessWidget {
  const LeagueView({
    super.key,
    required this.league,
  });

  final League league;

  static const double _headerFontSize = 20;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 40,
              child: Row(
                children: [
                  Text(
                    'Liga ${league.leagueNo}',
                    style: const TextStyle(fontSize: _headerFontSize),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.sports_volleyball),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SizedBox(
                width: 500,
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    var element = league.scheduledGames[index];
                    return ScheduleEntry(matchScheduleEntry: element);
                  },
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: league.scheduledGames.length,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ScheduleEntry extends StatelessWidget {
  const ScheduleEntry({
    super.key,
    required this.matchScheduleEntry,
  });

  final MatchScheduleEntry matchScheduleEntry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 150,
          child: Row(
            children: [
              Text('Platz ${matchScheduleEntry.field}'),
              const SizedBox(width: 5),
              const Text('|'),
              const SizedBox(width: 5),
              Text(matchScheduleEntry.startTime),
            ],
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(matchScheduleEntry.team1),
              const SizedBox(width: 5),
              const Text(':'),
              const SizedBox(width: 5),
              Text(matchScheduleEntry.team2),
            ],
          ),
        ),
      ],
    );
  }
}
