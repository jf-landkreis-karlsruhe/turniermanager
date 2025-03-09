import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:tournament_manager/src/manager/game_manager.dart';
import 'package:tournament_manager/src/model/referee/age_group.dart';
import 'package:tournament_manager/src/model/schedule/league.dart';
import 'package:tournament_manager/src/model/schedule/match_schedule_entry.dart';
import 'package:watch_it/watch_it.dart';

class ScheduleView extends StatefulWidget with WatchItStatefulWidgetMixin {
  const ScheduleView(
    this.ageGroup, {
    super.key,
  });

  final AgeGroup ageGroup;

  static const routeName = '/schedule';
  static const ageGroupQueryParam = 'ageGroup';

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  Timer? refreshTimer;
  final double _headerFontSize = 26;

  final ItemScrollController itemScrollController = ItemScrollController();
  var currentScrollIndex = 1;
  var amountItems = 0;

  @override
  void initState() {
    if (refreshTimer != null) {
      refreshTimer?.cancel();
      refreshTimer = null;
    }

    refreshTimer ??= Timer.periodic(const Duration(seconds: 10), (timer) {
      final GameManager gameManager = di<GameManager>();
      gameManager.getScheduleCommand(widget.ageGroup.id);

      if (amountItems > 0) {
        itemScrollController.scrollTo(
            index: currentScrollIndex,
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOutCubic);

        currentScrollIndex++;
      }
      if (currentScrollIndex >= amountItems) {
        currentScrollIndex = 0;
      }
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
    amountItems = schedule.leagueSchedules.length;

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
            widget.ageGroup.name,
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
        child: ScrollablePositionedList.builder(
          itemScrollController: itemScrollController,
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
                    league.leagueName,
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
              color: Colors.indigo,
              width: 500,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    var element = league.entries[index];
                    return ScheduleEntryView(matchScheduleEntry: element);
                  },
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: league.entries.length,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ScheduleEntryView extends StatelessWidget {
  const ScheduleEntryView({
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
                matchScheduleEntry.pitchName,
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
                matchScheduleEntry.teamAName,
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(width: 5),
              const Text(
                ':',
                style: TextStyle(color: Colors.black),
              ),
              const SizedBox(width: 5),
              Text(
                matchScheduleEntry.teamBName,
                style: const TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
