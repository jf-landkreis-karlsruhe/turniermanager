import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:separated_column/separated_column.dart';
import 'package:separated_row/separated_row.dart';
import 'package:tournament_manager/src/Constants.dart';
import 'package:tournament_manager/src/helper/error_helper.dart';
import 'package:tournament_manager/src/manager/game_manager.dart';
import 'package:watch_it/watch_it.dart';

class AdminView extends StatelessWidget {
  const AdminView({super.key});

  static const routeName = '/admin';

  @override
  Widget build(BuildContext context) {
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
        child: ListView(children: [
          GameScoreView(),
          const SizedBox(height: 10),
          const PitchPrinter(),
        ]),
      ),
    );
  }
}

class PitchPrinter extends StatelessWidget with WatchItMixin {
  const PitchPrinter({super.key});

  @override
  Widget build(BuildContext context) {
    var pitches = watchPropertyValue((GameManager manager) => manager.pitches);
    List<Widget> pitchWidgets = pitches.map(
      (pitch) {
        return SeparatedRow(
          separatorBuilder: (context, index) => const SizedBox(width: 10),
          children: [
            Text('${pitch.name} (ID: ${pitch.id})'),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.print),
            ),
          ],
        );
      },
    ).toList();

    return SeparatedColumn(
      crossAxisAlignment: CrossAxisAlignment.start,
      separatorBuilder: (_, index) => const SizedBox(height: 10),
      children: [
        SeparatedRow(
          separatorBuilder: (context, index) => const SizedBox(width: 10),
          children: [
            const Text(
              'Schiedsrichterzettel',
              style: Constants.mediumHeaderTextStyle,
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.print),
              tooltip: 'Alles drucken',
            ),
          ],
        ),
        ...pitchWidgets
      ],
    );
  }
}

class GameScoreView extends StatelessWidget with WatchItMixin {
  GameScoreView({super.key});

  final _gameManager = di<GameManager>();

  @override
  Widget build(BuildContext context) {
    var games = watchPropertyValue((GameManager manager) => manager.games);

    List<DataColumn> columns = [
      addDataColumn('#'),
      addDataColumn('Startzeit'),
      addDataColumn('Platz'),
      addDataColumn('Altersklasse'),
      addDataColumn('Liga'),
      addDataColumn('Team A Name'),
      addDataColumn('Team A Score'),
      addDataColumn(':'),
      addDataColumn('Team B Score'),
      addDataColumn('Team B Name'),
      addDataColumn('Actions'),
    ];

    List<DataRow> rows = [];
    for (var game in games) {
      final teamAController = TextEditingController();
      final teamBController = TextEditingController();

      List<DataCell> cells = [
        addDataCell(game.gameNumber.toString()),
        addDataCell(DateFormat.Hm()
            .format(DateTime.now())), //TODO: get starttime from dto & sort
        addDataCell(game.pitch.name),
        addDataCell(game.ageGroupName),
        addDataCell(game.leagueName),
        addDataCell(game.teamA.name),
        DataCell(
          TextField(
            controller: teamAController,
          ),
        ),
        addDataCell(':'),
        DataCell(
          TextField(
            controller: teamBController,
          ),
        ),
        addDataCell(game.teamB.name),
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
      ];

      rows.add(DataRow(cells: cells));
    }

    return SeparatedColumn(
      crossAxisAlignment: CrossAxisAlignment.start,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      children: [
        const Text(
          'Spielwertungen',
          style: Constants.mediumHeaderTextStyle,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: columns,
            rows: rows,
          ),
        ),
      ],
    );
  }
}

DataColumn addDataColumn(String header) {
  var columnHeaderTextStyle = Constants.standardTextStyle.copyWith(
    fontWeight: FontWeight.bold,
  );

  return DataColumn(
    label: Text(
      header,
      style: columnHeaderTextStyle,
    ),
  );
}

DataCell addDataCell(String text) {
  return DataCell(
    Text(
      text,
      style: Constants.standardTextStyle,
    ),
  );
}
