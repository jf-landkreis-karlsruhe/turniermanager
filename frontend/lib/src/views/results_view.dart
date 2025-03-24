import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:tournament_manager/src/Constants.dart';
import 'package:tournament_manager/src/manager/game_manager.dart';
import 'package:tournament_manager/src/model/age_group.dart';
import 'package:tournament_manager/src/model/results/league.dart';
import 'package:watch_it/watch_it.dart';

class ResultsView extends StatefulWidget with WatchItStatefulWidgetMixin {
  const ResultsView(
    this.ageGroup, {
    super.key,
  });

  final AgeGroup ageGroup;

  static const routeName = '/results';
  static const ageGroupQueryParam = 'ageGroup';

  @override
  State<ResultsView> createState() => _ResultsViewState();
}

class _ResultsViewState extends State<ResultsView> {
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
      gameManager.getResultsCommand(widget.ageGroup.id);

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
    var results = watchPropertyValue((GameManager manager) => manager.results);
    amountItems = results.leagueTables.length;

    var screenSize = MediaQuery.sizeOf(context);
    var amountLeagues = results.leagueTables.length;
    var enclosingPadding = 20;
    var leaguePadding = amountLeagues > 1 ? 10 : 0;
    var displayFactor = amountLeagues > 1 ? 2 : 1;
    var leagueWidgetSize =
        (screenSize.width - enclosingPadding - leaguePadding) / displayFactor;
    leagueWidgetSize = leagueWidgetSize < 750
        ? screenSize.width - enclosingPadding
        : leagueWidgetSize;

    return Scaffold(
      appBar: AppBar(
        leading: const Center(
          child: Text(
            'Ergebnisse',
            style: Constants.largeHeaderTextStyle,
          ),
        ),
        leadingWidth: 150,
        actions: [
          Text(
            widget.ageGroup.name,
            style: Constants.largeHeaderTextStyle,
          ),
          const SizedBox(width: 5),
          const Text(
            '|',
            style: Constants.largeHeaderTextStyle,
          ),
          const SizedBox(width: 5),
          Text(
            results.roundName,
            style: Constants.largeHeaderTextStyle,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(enclosingPadding / 2),
        child: ScrollablePositionedList.builder(
          itemScrollController: itemScrollController,
          scrollDirection: Axis.horizontal,
          itemCount: results.leagueTables.length,
          itemBuilder: (context, index) {
            var entry = results.leagueTables[index];
            return LeagueView(
              league: entry,
              width: leagueWidgetSize,
            );
          },
        ),
      ),
    );
  }
}

enum LeagueWidgetSize {
  small,
  medium,
  large,
}

class LeagueView extends StatelessWidget {
  const LeagueView({
    super.key,
    required this.league,
    required this.width,
  });

  final League league;
  final double width;

  final Color textColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    LeagueWidgetSize leagueWidgetSize = LeagueWidgetSize.large;
    if (width < 750 && width > 500) {
      leagueWidgetSize = LeagueWidgetSize.medium;
    } else if (width <= 500) {
      leagueWidgetSize = LeagueWidgetSize.small;
    }

    var columnHeaderTextStyle = Constants.standardTextStyle.copyWith(
      fontWeight: FontWeight.bold,
      color: textColor,
    );
    var columnEntryTextStyle = Constants.standardTextStyle.copyWith(
      color: textColor,
    );

    List<DataColumn> columns = [];
    columns.add(DataColumn(
      label: Text(
        '#',
        style: columnHeaderTextStyle,
      ),
    ));

    columns.add(DataColumn(
      label: Text(
        'Mannschaft',
        style: columnHeaderTextStyle,
      ),
    ));

    if (leagueWidgetSize == LeagueWidgetSize.large ||
        leagueWidgetSize == LeagueWidgetSize.medium) {
      columns.add(DataColumn(
        label: Text(
          'S',
          style: columnHeaderTextStyle,
        ),
      ));

      columns.add(DataColumn(
        label: Text(
          'U',
          style: columnHeaderTextStyle,
        ),
      ));

      columns.add(DataColumn(
        label: Text(
          'N',
          style: columnHeaderTextStyle,
        ),
      ));
    }

    if (leagueWidgetSize == LeagueWidgetSize.large) {
      columns.add(DataColumn(
        label: Text(
          'Sätze',
          style: columnHeaderTextStyle,
        ),
      ));

      columns.add(DataColumn(
        label: Text(
          'Diff.',
          style: columnHeaderTextStyle,
        ),
      ));
    }

    columns.add(DataColumn(
      label: Text(
        'Pkt.',
        style: columnHeaderTextStyle,
      ),
    ));

    List<DataRow> rows = [];
    for (var result in league.teams) {
      var index = league.teams.indexOf(result) + 1;
      List<DataCell> cells = [];

      cells.add(
        DataCell(
          Text(
            index.toString(),
            style: columnEntryTextStyle,
          ),
        ),
      );

      cells.add(
        DataCell(
          Text(
            result.teamName,
            style: columnEntryTextStyle,
          ),
        ),
      );

      if (leagueWidgetSize == LeagueWidgetSize.large ||
          leagueWidgetSize == LeagueWidgetSize.medium) {
        cells.add(
          DataCell(
            Text(
              result.victories.toString(),
              style: columnEntryTextStyle,
            ),
          ),
        );

        cells.add(
          DataCell(
            Text(
              result.draws.toString(),
              style: columnEntryTextStyle,
            ),
          ),
        );

        cells.add(
          DataCell(
            Text(
              result.defeats.toString(),
              style: columnEntryTextStyle,
            ),
          ),
        );
      }

      if (leagueWidgetSize == LeagueWidgetSize.large) {
        cells.add(
          DataCell(
            Text(
              '${result.ownScoredGoals} : ${result.enemyScoredGoals}',
              style: columnEntryTextStyle,
            ),
          ),
        );

        cells.add(
          DataCell(
            Text(
              (result.ownScoredGoals - result.enemyScoredGoals).toString(),
              style: columnEntryTextStyle,
            ),
          ),
        );
      }

      cells.add(
        DataCell(
          Text(
            result.totalPoints.toString(),
            style: columnEntryTextStyle,
          ),
        ),
      );

      rows.add(DataRow(cells: cells));
    }

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
                child: DataTable(columns: columns, rows: rows),
              ),
            ),
          )
        ],
      ),
    );
  }
}
