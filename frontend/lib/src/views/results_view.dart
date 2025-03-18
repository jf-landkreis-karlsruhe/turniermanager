import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
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
        leading: Center(
          child: Text(
            'Ergebnisse',
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
            results.roundName,
            style: TextStyle(fontSize: _headerFontSize),
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

  static const double _headerFontSize = 20;
  final Color textColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    LeagueWidgetSize leagueWidgetSize = LeagueWidgetSize.large;
    if (width < 750 && width > 500) {
      leagueWidgetSize = LeagueWidgetSize.medium;
    } else if (width <= 500) {
      leagueWidgetSize = LeagueWidgetSize.small;
    }

    List<DataColumn> columns = [];
    columns.add(DataColumn(
      label: Text(
        '#',
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    ));

    columns.add(DataColumn(
      label: Text(
        'Mannschaft',
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    ));

    if (leagueWidgetSize == LeagueWidgetSize.large ||
        leagueWidgetSize == LeagueWidgetSize.medium) {
      columns.add(DataColumn(
        label: Text(
          'S',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ));

      columns.add(DataColumn(
        label: Text(
          'U',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ));

      columns.add(DataColumn(
        label: Text(
          'N',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ));
    }

    if (leagueWidgetSize == LeagueWidgetSize.large) {
      columns.add(DataColumn(
        label: Text(
          'Sätze',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ));

      columns.add(DataColumn(
        label: Text(
          'Diff.',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ));
    }

    columns.add(DataColumn(
      label: Text(
        'Pkt.',
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
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
            style: TextStyle(color: textColor),
          ),
        ),
      );

      cells.add(
        DataCell(
          Text(
            result.teamName,
            style: TextStyle(color: textColor),
          ),
        ),
      );

      if (leagueWidgetSize == LeagueWidgetSize.large ||
          leagueWidgetSize == LeagueWidgetSize.medium) {
        cells.add(
          DataCell(
            Text(
              result.victories.toString(),
              style: TextStyle(color: textColor),
            ),
          ),
        );

        cells.add(
          DataCell(
            Text(
              result.draws.toString(),
              style: TextStyle(color: textColor),
            ),
          ),
        );

        cells.add(
          DataCell(
            Text(
              result.defeats.toString(),
              style: TextStyle(color: textColor),
            ),
          ),
        );
      }

      if (leagueWidgetSize == LeagueWidgetSize.large) {
        cells.add(
          DataCell(
            Text(
              '${result.ownScoredGoals} : ${result.enemyScoredGoals}',
              style: TextStyle(color: textColor),
            ),
          ),
        );

        cells.add(
          DataCell(
            Text(
              (result.ownScoredGoals - result.enemyScoredGoals).toString(),
              style: TextStyle(color: textColor),
            ),
          ),
        );
      }

      cells.add(
        DataCell(
          Text(
            result.totalPoints.toString(),
            style: TextStyle(color: textColor),
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
