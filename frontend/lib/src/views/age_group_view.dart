import 'package:flutter/material.dart';
import 'package:separated_column/separated_column.dart';
import 'package:tournament_manager/src/constants.dart';
import 'package:tournament_manager/src/manager/game_manager.dart';
import 'package:tournament_manager/src/views/results_view.dart';
import 'package:tournament_manager/src/views/schedule_view.dart';
import 'package:watch_it/watch_it.dart';

class AgeGroupView extends StatelessWidget with WatchItMixin {
  const AgeGroupView({
    super.key,
    required this.ageGroupName,
  });

  final String ageGroupName;

  static const routeName = '/scheduleandresults';
  static const ageGroupQueryParam = 'ageGroup';

  @override
  Widget build(BuildContext context) {
    final GameManager gameManager = di<GameManager>();
    watchPropertyValue((GameManager manager) =>
        manager.ageGroups); // listen to updates for agegroups
    var ageGroup = gameManager.getAgeGroupByName(ageGroupName);

    if (ageGroup == null) {
      return Center(
        child: Text('Altersklasse "$ageGroupName" nicht vorhanden!'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: const Center(
          child: Text(
            'Spielplan & Ergebnisse',
            style: Constants.largeHeaderTextStyle,
          ),
        ),
        leadingWidth: 300,
        actions: [
          Text(
            ageGroup.name,
            style: Constants.largeHeaderTextStyle,
          ),
        ],
      ),
      body: SeparatedColumn(
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        children: [
          Expanded(
            child: ScheduleContentView(ageGroup: ageGroup),
          ),
          Expanded(
            flex: 2,
            child: ResultsContentView(ageGroup: ageGroup),
          ),
        ],
      ),
    );
  }
}
