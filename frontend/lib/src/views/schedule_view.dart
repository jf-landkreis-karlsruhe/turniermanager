import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:tournament_manager/src/Constants.dart';
import 'package:tournament_manager/src/manager/game_manager.dart';
import 'package:tournament_manager/src/model/age_group.dart';
import 'package:tournament_manager/src/model/schedule/league.dart';
import 'package:tournament_manager/src/model/schedule/match_schedule_entry.dart';
import 'package:watch_it/watch_it.dart';

class ScheduleView extends StatelessWidget with WatchItMixin {
  const ScheduleView(
    this.ageGroup, {
    super.key,
  });

  final AgeGroup ageGroup;

  static const routeName = '/schedule';
  static const ageGroupQueryParam = 'ageGroup';

  @override
  Widget build(BuildContext context) {
    var schedule =
        watchPropertyValue((GameManager manager) => manager.schedule);

    return Scaffold(
      appBar: AppBar(
        leading: const Center(
          child: Text(
            'Spielplan',
            style: Constants.largeHeaderTextStyle,
          ),
        ),
        leadingWidth: 150,
        actions: [
          Text(
            ageGroup.name,
            style: Constants.largeHeaderTextStyle,
          ),
          const SizedBox(width: 5),
          const Text(
            '|',
            style: Constants.largeHeaderTextStyle,
          ),
          const SizedBox(width: 5),
          Text(
            schedule.roundName,
            style: Constants.largeHeaderTextStyle,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: ScheduleContentView(ageGroup: ageGroup),
    );
  }
}

class ScheduleContentView extends StatefulWidget
    with WatchItStatefulWidgetMixin {
  const ScheduleContentView({
    super.key,
    required this.ageGroup,
  });

  final AgeGroup ageGroup;

  @override
  State<ScheduleContentView> createState() => _ScheduleContentViewState();
}

class _ScheduleContentViewState extends State<ScheduleContentView> {
  Timer? refreshTimer;

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

    var screenSize = MediaQuery.sizeOf(context);
    var amountLeagues = schedule.leagueSchedules.length;
    var enclosingPadding = 20;
    var leaguePadding = amountLeagues > 1 ? 10 : 0;
    var displayFactor = amountLeagues > 1 ? 2 : 1;
    var leagueWidgetSize =
        (screenSize.width - enclosingPadding - leaguePadding) / displayFactor;
    leagueWidgetSize = leagueWidgetSize < 500
        ? screenSize.width - enclosingPadding
        : leagueWidgetSize;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ScrollablePositionedList.builder(
        itemScrollController: itemScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: schedule.leagueSchedules.length,
        itemBuilder: (context, index) {
          var entry = schedule.leagueSchedules[index];
          return LeagueView(
            league: entry,
            width: leagueWidgetSize,
          );
        },
      ),
    );
  }
}

class LeagueView extends StatelessWidget {
  const LeagueView({
    super.key,
    required this.league,
    required this.width,
  });

  final League league;
  final double width;

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
                    style: Constants.mediumHeaderTextStyle,
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.sports_volleyball),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey[800],
              width: width,
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
  final Color textColor = Colors.white;

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
                style: Constants.standardTextStyle,
              ),
              const SizedBox(width: 5),
              const Text(
                '|',
                style: Constants.standardTextStyle,
              ),
              const SizedBox(width: 5),
              Text(
                DateFormat.Hm().format(matchScheduleEntry.startTime),
                style: Constants.standardTextStyle,
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
                style: Constants.standardTextStyle,
              ),
              const SizedBox(width: 5),
              const Text(
                ':',
                style: Constants.standardTextStyle,
              ),
              const SizedBox(width: 5),
              Text(
                matchScheduleEntry.teamBName,
                style: Constants.standardTextStyle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
