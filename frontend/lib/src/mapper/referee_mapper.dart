import 'package:tournament_manager/src/model/referee/age_group.dart';
import 'package:tournament_manager/src/model/referee/game.dart';
import 'package:tournament_manager/src/model/referee/league.dart';
import 'package:tournament_manager/src/model/referee/pitch.dart';
import 'package:tournament_manager/src/model/referee/round.dart';
import 'package:tournament_manager/src/model/referee/team.dart';
import 'package:tournament_manager/src/serialization/referee/age_group_dto.dart';
import 'package:tournament_manager/src/serialization/referee/game_dto.dart';
import 'package:tournament_manager/src/serialization/referee/league_dto.dart';
import 'package:tournament_manager/src/serialization/referee/pitch_dto.dart';
import 'package:tournament_manager/src/serialization/referee/round_dto.dart';
import 'package:tournament_manager/src/serialization/referee/team_dto.dart';

class ResultsMapper {
  AgeGroup mapAgeGroup(AgeGroupDto dto) {
    return AgeGroup(dto.name);
  }

  League mapLeague(LeagueDto dto) {
    return League(dto.name);
  }

  Pitch mapPitch(PitchDto dto) {
    return Pitch(dto.name);
  }

  Round mapRound(RoundDto dto) {
    return Round(dto.name)
      ..games = dto.games.map((game) => mapGame(game)).toList();
  }

  Team mapTeam(TeamDto dto) {
    return Team(
      dto.name,
      mapAgeGroup(dto.ageGroup),
      mapLeague(dto.league),
    );
  }

  Game mapGame(GameDto dto) {
    return Game(
      dto.gameNumber,
      mapPitch(dto.pitch),
      mapTeam(dto.teamA),
      mapTeam(dto.teamB),
    );
  }
}
