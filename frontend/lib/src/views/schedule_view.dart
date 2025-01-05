import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tournament_manager/src/manager/game_manager.dart';
import 'package:tournament_manager/src/model/league.dart';
import 'package:tournament_manager/src/model/match_schedule_entry.dart';
import 'package:watch_it/watch_it.dart';

class ScheduleView extends StatefulWidget with WatchItStatefulWidgetMixin {
  const ScheduleView(
    this.ageGroup, {
    super.key,
  });

  final String ageGroup;

  static const routeName = '/schedule';
  static const ageGroupQueryParam = 'ageGroup';

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  Timer? refreshTimer;
  final double _headerFontSize = 26;

  @override
  void initState() {
    if (refreshTimer != null) {
      refreshTimer?.cancel();
      refreshTimer = null;
    }

    refreshTimer ??= Timer.periodic(const Duration(seconds: 10), (timer) {
      final GameManager gameManager = di<GameManager>();
      gameManager.getGameDataCommand(widget.ageGroup);
    });

    super.initState();
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    refreshTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var schedule =
        watchPropertyValue((GameManager manager) => manager.schedule);

    return Scaffold(
      appBar: AppBar(
        leading: Center(
          child: Text(
            'Spielplan',
            style: TextStyle(fontSize: _headerFontSize),
          ),
        ),
        leadingWidth: 150,
        actions: [
          Text(
            'Altersklasse ${widget.ageGroup}',
            style: TextStyle(fontSize: _headerFontSize),
          ),
          const SizedBox(width: 5),
          Text(
            '|',
            style: TextStyle(fontSize: _headerFontSize),
          ),
          const SizedBox(width: 5),
          Text(
            'Spielrunde ${schedule.matchRound}',
            style: TextStyle(fontSize: _headerFontSize),
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
                    'Liga ${league.leagueNo}',
                    style: const TextStyle(fontSize: _headerFontSize),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.sports_volleyball),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey,
              width: 500,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    var element = league.scheduledGames[index];
                    return ScheduleEntry(matchScheduleEntry: element);
                  },
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: league.scheduledGames.length,
                ),
              ),
            ),
          )
        ],
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
              Text(
                'Platz ${matchScheduleEntry.field}',
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(width: 5),
              const Text(
                '|',
                style: TextStyle(color: Colors.black),
              ),
              const SizedBox(width: 5),
              Text(
                matchScheduleEntry.startTime,
                style: const TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                matchScheduleEntry.team1,
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(width: 5),
              const Text(
                ':',
                style: TextStyle(color: Colors.black),
              ),
              const SizedBox(width: 5),
              Text(
                matchScheduleEntry.team2,
                style: const TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
