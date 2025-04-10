import 'package:tournament_manager/src/model/referee/game.dart';
import 'package:tournament_manager/src/model/referee/game_group.dart';
import 'package:tournament_manager/src/model/referee/game_settings.dart';
import 'package:tournament_manager/src/model/referee/pitch.dart';
import 'package:tournament_manager/src/model/referee/round_settings.dart';
import 'package:tournament_manager/src/model/referee/team.dart';
import 'package:tournament_manager/src/serialization/referee/game_dto.dart';
import 'package:tournament_manager/src/serialization/referee/game_group_dto.dart';
import 'package:tournament_manager/src/serialization/referee/game_settings_dto.dart';
import 'package:tournament_manager/src/serialization/referee/pitch_dto.dart';
import 'package:tournament_manager/src/serialization/referee/round_settings_dto.dart';
import 'package:tournament_manager/src/serialization/referee/team_dto.dart';

class RefereeMapper {
  Pitch mapPitch(PitchDto dto) {
    return Pitch(
      dto.id,
      dto.name,
    );
  }

  GameGroup mapGameGroup(GameGroupDto dto) {
    return GameGroup(
      dto.startTime,
      dto.gameDurationInMinutes,
    )..games = dto.games.map((game) => mapGame(game)).toList();
  }

  Team mapTeam(TeamDto dto) {
    return Team(
      dto.name,
    );
  }

  Game mapGame(GameDto dto) {
    return Game(
      dto.gameNumber,
      mapPitch(dto.pitch),
      mapTeam(dto.teamA),
      mapTeam(dto.teamB),
      dto.leagueName,
      dto.ageGroupName,
    );
  }

  RoundSettings mapRoundSettings(RoundSettingsDto dto) {
    return RoundSettings(mapGameSettings(dto.gameSettings))
      ..numberPerRounds = dto.numberPerRounds;
  }

  GameSettings mapGameSettings(GameSettingsDto dto) {
    return GameSettings(
      dto.startTime,
      dto.breakTime,
      dto.playTime,
    );
  }

  RoundSettingsDto reverseMapRoundSettings(RoundSettings model) {
    return RoundSettingsDto(reverseMapGameSettings(model.gameSettings))
      ..numberPerRounds = model.numberPerRounds;
  }

  GameSettingsDto reverseMapGameSettings(GameSettings model) {
    return GameSettingsDto(
      model.startTime,
      model.breakTime,
      model.playTime,
    );
  }
}
