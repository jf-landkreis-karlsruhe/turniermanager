import 'package:tournament_manager/src/model/results/league.dart';

class Results {
  Results(this.roundName);

  String roundName;
  List<League> leagueTables = [];
}
