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
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 20),
            Expanded(
              child: SizedBox(
                width: 500,
                child: ListView(
                  children: league.scheduledGames
                      .map((element) =>
                          ScheduleEntry(matchScheduleEntry: element))
                      .toList(),
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
