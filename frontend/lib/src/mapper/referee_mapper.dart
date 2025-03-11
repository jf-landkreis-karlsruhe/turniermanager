import 'package:tournament_manager/src/model/referee/age_group.dart';
import 'package:tournament_manager/src/model/referee/game.dart';
import 'package:tournament_manager/src/model/referee/game_group.dart';
import 'package:tournament_manager/src/model/referee/league.dart';
import 'package:tournament_manager/src/model/referee/pitch.dart';
import 'package:tournament_manager/src/model/referee/team.dart';
import 'package:tournament_manager/src/serialization/referee/age_group_dto.dart';
import 'package:tournament_manager/src/serialization/referee/game_dto.dart';
import 'package:tournament_manager/src/serialization/referee/game_group_dto.dart';
import 'package:tournament_manager/src/serialization/referee/league_dto.dart';
import 'package:tournament_manager/src/serialization/referee/pitch_dto.dart';
import 'package:tournament_manager/src/serialization/referee/team_dto.dart';

class RefereeMapper {
  AgeGroup mapAgeGroup(AgeGroupDto dto) {
    return AgeGroup(dto.id, dto.name);
  }

  League mapLeague(LeagueDto dto) {
    return League(dto.name);
  }

  Pitch mapPitch(PitchDto dto) {
    return Pitch(dto.name);
  }

  GameGroup mapGameGroup(GameGroupDto dto) {
    return GameGroup(dto.startTime)
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
