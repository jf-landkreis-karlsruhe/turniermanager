import 'package:tournament_manager/src/model/tournament.dart';
import 'package:tournament_manager/src/serialization/tournament_dto.dart';

class TournamentMapper {
  Tournament map(TournamentDto dto) {
    return Tournament(dto.id)..ageGroups = dto.ageGroups;
  }
}
