import 'package:tournament_manager/src/model/results/result_entry.dart';

class League {
  League(this.leagueName);

  String leagueName;
  List<ResultEntry> teams = [];
}
