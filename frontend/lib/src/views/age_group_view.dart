import 'package:flutter/material.dart';
import 'package:separated_column/separated_column.dart';
import 'package:tournament_manager/src/constants.dart';
import 'package:tournament_manager/src/model/age_group.dart';
import 'package:tournament_manager/src/views/results_view.dart';
import 'package:tournament_manager/src/views/schedule_view.dart';

class AgeGroupView extends StatelessWidget {
  const AgeGroupView({
    super.key,
    required this.ageGroup,
  });

  final AgeGroup ageGroup;

  static const routeName = '/scheduleandresults';
  static const ageGroupQueryParam = 'ageGroup';

  @override
  Widget build(BuildContext context) {
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
