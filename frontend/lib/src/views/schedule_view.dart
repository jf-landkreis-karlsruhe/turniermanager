import 'package:flutter/material.dart';
import 'package:tournament_manager/src/manager/game_manager.dart';
import 'package:watch_it/watch_it.dart';

class ScheduleView extends StatelessWidget with WatchItMixin {
  const ScheduleView(
    this.ageGroup,
    this.league, {
    super.key,
  });

  final String ageGroup;
  final String league;

  static const routeName = '/schedule';
  static const ageGroupQueryParam = 'ageGroup';
  static const leagueQueryParam = 'league';

  @override
  Widget build(BuildContext context) {
    var schedule =
        watchPropertyValue((GameManager manager) => manager.schedule);

    return ListView.builder(
      itemCount: schedule.entries.length,
      itemBuilder: (context, index) {
        var entry = schedule.entries[index];

        return Row(
          children: [
            Text(entry.field),
            const SizedBox(width: 10),
            Text(entry.team1),
            const SizedBox(width: 10),
            Text(entry.team2),
          ],
        );
      },
    );
  }
}
