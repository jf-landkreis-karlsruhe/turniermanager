import 'package:flutter/material.dart';
import 'package:tournament_manager/src/manager/game_manager.dart';
import 'package:watch_it/watch_it.dart';

class AdminView extends StatelessWidget with WatchItMixin {
  AdminView({super.key});

  static const routeName = '/admin';
  final double _headerFontSize = 26;
  static const Color _textColor = Colors.white;
  static const _columnHeaderTextStyle = TextStyle(
    color: _textColor,
    fontWeight: FontWeight.bold,
  );

  static const _textStyle = TextStyle(color: _textColor);

  final _teamAController = TextEditingController();
  final _teamBController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var games = watchPropertyValue((GameManager manager) => manager.games);

    List<DataColumn> columns = [];

    columns.add(
      const DataColumn(
        label: Text(
          '#',
          style: _columnHeaderTextStyle,
        ),
      ),
    );

    columns.add(
      const DataColumn(
        label: Text(
          'Platz',
          style: _columnHeaderTextStyle,
        ),
      ),
    );

    columns.add(
      const DataColumn(
        label: Text(
          'Altersklasse',
          style: _columnHeaderTextStyle,
        ),
      ),
    );

    columns.add(
      const DataColumn(
        label: Text(
          'Liga',
          style: _columnHeaderTextStyle,
        ),
      ),
    );

    columns.add(
      const DataColumn(
        label: Text(
          'Team A Name',
          style: _columnHeaderTextStyle,
        ),
      ),
    );

    columns.add(
      const DataColumn(
        label: Text(
          'Team A Score',
          style: _columnHeaderTextStyle,
        ),
      ),
    );

    columns.add(
      const DataColumn(
        label: Text(
          ':',
          style: _columnHeaderTextStyle,
        ),
      ),
    );

    columns.add(
      const DataColumn(
        label: Text(
          'Team B Score',
          style: _columnHeaderTextStyle,
        ),
      ),
    );

    columns.add(
      const DataColumn(
        label: Text(
          'Team B Name',
          style: _columnHeaderTextStyle,
        ),
      ),
    );

    columns.add(
      const DataColumn(
        label: Text(
          'Actions',
          style: _columnHeaderTextStyle,
        ),
      ),
    );

    List<DataRow> rows = [];
    for (var game in games) {
      List<DataCell> cells = [];

      cells.add(
        DataCell(
          Text(
            game.gameNumber.toString(),
            style: _textStyle,
          ),
        ),
      );

      cells.add(
        DataCell(
          Text(
            game.pitch.name,
            style: _textStyle,
          ),
        ),
      );

      cells.add(
        DataCell(
          Text(
            game.ageGroupName,
            style: _textStyle,
          ),
        ),
      );

      cells.add(
        DataCell(
          Text(
            game.leagueName,
            style: _textStyle,
          ),
        ),
      );

      cells.add(
        DataCell(
          Text(
            game.teamA.name,
            style: _textStyle,
          ),
        ),
      );

      cells.add(
        DataCell(TextField(
          controller: _teamAController,
        )),
      );

      cells.add(
        const DataCell(
          Text(
            ':',
            style: _textStyle,
          ),
        ),
      );

      cells.add(
        DataCell(TextField(
          controller: _teamBController,
        )),
      );

      cells.add(
        DataCell(
          Text(
            game.teamB.name,
            style: _textStyle,
          ),
        ),
      );

      cells.add(
        DataCell(
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.save),
          ),
        ),
      );

      rows.add(DataRow(cells: cells));
    }

    return Scaffold(
      appBar: AppBar(
        leading: Center(
          child: Text(
            'Admin',
            style: TextStyle(fontSize: _headerFontSize),
          ),
        ),
        leadingWidth: 100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: DataTable(columns: columns, rows: rows),
      ),
    );
  }
}
