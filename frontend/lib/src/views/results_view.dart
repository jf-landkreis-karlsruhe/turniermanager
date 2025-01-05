import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tournament_manager/src/manager/game_manager.dart';
import 'package:tournament_manager/src/model/results/league.dart';
import 'package:watch_it/watch_it.dart';

class ResultsView extends StatefulWidget with WatchItStatefulWidgetMixin {
  const ResultsView(
    this.ageGroup, {
    super.key,
  });

  final String ageGroup;

  static const routeName = '/results';
  static const ageGroupQueryParam = 'ageGroup';

  @override
  State<ResultsView> createState() => _ResultsViewState();
}

class _ResultsViewState extends State<ResultsView> {
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
      gameManager.getResultsCommand(widget.ageGroup);
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
            'Spielrunde ${results.matchRound}',
            style: TextStyle(fontSize: _headerFontSize),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: results.leagueResults.length,
          itemBuilder: (context, index) {
            var entry = results.leagueResults[index];
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
    List<DataColumn> columns = [
      const DataColumn(
        label: Text(
          '#',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const DataColumn(
        label: Text(
          'Mannschaft',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const DataColumn(
        label: Text(
          'S',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const DataColumn(
        label: Text(
          'U',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const DataColumn(
        label: Text(
          'N',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const DataColumn(
        label: Text(
          'Sätze',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const DataColumn(
        label: Text(
          'Diff.',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const DataColumn(
        label: Text(
          'Pkt.',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ];

    List<DataRow> rows = [];
    for (var result in league.gameResults) {
      var index = league.gameResults.indexOf(result) + 1;
      List<DataCell> cells = [];
      cells.add(
        DataCell(
          Text(
            index.toString(),
            style: const TextStyle(color: Colors.black),
          ),
        ),
      );
      cells.add(
        DataCell(
          Text(
            result.teamName,
            style: const TextStyle(color: Colors.black),
          ),
        ),
      );
      cells.add(
        DataCell(
          Text(
            result.amountWins.toString(),
            style: const TextStyle(color: Colors.black),
          ),
        ),
      );
      cells.add(
        DataCell(
          Text(
            result.amountDraws.toString(),
            style: const TextStyle(color: Colors.black),
          ),
        ),
      );
      cells.add(
        DataCell(
          Text(
            result.amountDefeats.toString(),
            style: const TextStyle(color: Colors.black),
          ),
        ),
      );
      cells.add(
        DataCell(
          Text(
            '${result.goals} : ${result.goalsConceded}',
            style: const TextStyle(color: Colors.black),
          ),
        ),
      );
      cells.add(
        DataCell(
          Text(
            (result.goals - result.goalsConceded).toString(),
            style: const TextStyle(color: Colors.black),
          ),
        ),
      );
      cells.add(
        DataCell(
          Text(
            result.points.toString(),
            style: const TextStyle(color: Colors.black),
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
              width: 750,
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
