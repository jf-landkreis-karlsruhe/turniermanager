import 'package:tournament_manager/src/model/referee/age_group.dart';
import 'package:tournament_manager/src/model/referee/league.dart';

class Team {
  Team(
    this.name,
    this.ageGroup,
    this.league,
  );

  String name;
  AgeGroup ageGroup;
  League league;
}
