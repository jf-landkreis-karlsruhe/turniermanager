import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tournament_manager/src/Constants.dart';
import 'package:tournament_manager/src/helper/error_helper.dart';
import 'package:tournament_manager/src/manager/game_manager.dart';
import 'package:watch_it/watch_it.dart';

class AdminView extends StatelessWidget with WatchItMixin {
  AdminView({super.key});

  static const routeName = '/admin';

  final _gameManager = di<GameManager>();

  @override
  Widget build(BuildContext context) {
    var textStyle = Constants.standardTextStyle;
    var columnHeaderTextStyle = Constants.standardTextStyle.copyWith(
      fontWeight: FontWeight.bold,
    );

    var games = watchPropertyValue((GameManager manager) => manager.games);

    List<DataColumn> columns = [];

    columns.add(
      DataColumn(
        label: Text(
          '#',
          style: columnHeaderTextStyle,
        ),
      ),
    );

    columns.add(
      DataColumn(
        label: Text(
          'Startzeit',
          style: columnHeaderTextStyle,
        ),
      ),
    );

    columns.add(
      DataColumn(
        label: Text(
          'Platz',
          style: columnHeaderTextStyle,
        ),
      ),
    );

    columns.add(
      DataColumn(
        label: Text(
          'Altersklasse',
          style: columnHeaderTextStyle,
        ),
      ),
    );

    columns.add(
      DataColumn(
        label: Text(
          'Liga',
          style: columnHeaderTextStyle,
        ),
      ),
    );

    columns.add(
      DataColumn(
        label: Text(
          'Team A Name',
          style: columnHeaderTextStyle,
        ),
      ),
    );

    columns.add(
      DataColumn(
        label: Text(
          'Team A Score',
          style: columnHeaderTextStyle,
        ),
      ),
    );

    columns.add(
      DataColumn(
        label: Text(
          ':',
          style: columnHeaderTextStyle,
        ),
      ),
    );

    columns.add(
      DataColumn(
        label: Text(
          'Team B Score',
          style: columnHeaderTextStyle,
        ),
      ),
    );

    columns.add(
      DataColumn(
        label: Text(
          'Team B Name',
          style: columnHeaderTextStyle,
        ),
      ),
    );

    columns.add(
      DataColumn(
        label: Text(
          'Actions',
          style: columnHeaderTextStyle,
        ),
      ),
    );

    List<DataRow> rows = [];
    for (var game in games) {
      final teamAController = TextEditingController();
      final teamBController = TextEditingController();
      List<DataCell> cells = [];

      cells.add(
        DataCell(
          Text(
            game.gameNumber.toString(),
            style: textStyle,
          ),
        ),
      );

      cells.add(
        DataCell(
          Text(
            DateFormat.Hm()
                .format(DateTime.now()), //TODO: get starttime from dto & sort
            style: textStyle,
          ),
        ),
      );

      cells.add(
        DataCell(
          Text(
            game.pitch.name,
            style: textStyle,
          ),
        ),
      );

      cells.add(
        DataCell(
          Text(
            game.ageGroupName,
            style: textStyle,
          ),
        ),
      );

      cells.add(
        DataCell(
          Text(
            game.leagueName,
            style: textStyle,
          ),
        ),
      );

      cells.add(
        DataCell(
          Text(
            game.teamA.name,
            style: textStyle,
          ),
        ),
      );

      cells.add(
        DataCell(TextField(
          controller: teamAController,
        )),
      );

      cells.add(
        DataCell(
          Text(
            ':',
            style: textStyle,
          ),
        ),
      );

      cells.add(
        DataCell(TextField(
          controller: teamBController,
        )),
      );

      cells.add(
        DataCell(
          Text(
            game.teamB.name,
            style: textStyle,
          ),
        ),
      );

      cells.add(
        DataCell(
          IconButton(
            onPressed: () async {
              var teamAScore = int.tryParse(teamAController.text);
              var teamBScore = int.tryParse(teamBController.text);

              if (teamAScore == null || teamBScore == null) {
                showError(context,
                    "Spiel #${game.gameNumber} konnte nicht gespeichert werden! Falsches Zahlenformat!");
                return;
              }

              var result =
                  await _gameManager.saveGameCommand.executeWithFuture((
                game.gameNumber,
                teamAScore,
                teamBScore,
              ));

              if (!context.mounted) {
                return;
              }

              if (!result) {
                showError(context,
                    "Spiel #${game.gameNumber} konnte nicht gespeichert werden! Server-Fehler / Exception!");
              }
            },
            icon: const Icon(Icons.save),
          ),
        ),
      );

      rows.add(DataRow(cells: cells));
    }

    return Scaffold(
      appBar: AppBar(
        leading: const Center(
          child: Text(
            'Admin',
            style: Constants.largeHeaderTextStyle,
          ),
        ),
        leadingWidth: 100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: DataTable(
          columns: columns,
          rows: rows,
        ),
      ),
    );
  }
}
