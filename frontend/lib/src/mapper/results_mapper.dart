import 'package:tournament_manager/src/model/results/league.dart';
import 'package:tournament_manager/src/model/results/result_entry.dart';
import 'package:tournament_manager/src/model/results/results.dart';
import 'package:tournament_manager/src/serialization/results/league_dto.dart';
import 'package:tournament_manager/src/serialization/results/result_entry_dto.dart';
import 'package:tournament_manager/src/serialization/results/results_dto.dart';

class ResultsMapper {
  Results map(ResultsDto dto) {
    return Results(dto.matchRound)
      ..leagueResults =
          dto.leagueResults.map((entry) => mapLeague(entry)).toList();
  }

  League mapLeague(LeagueDto dto) {
    return League(dto.leagueNo)
      ..gameResults = dto.gameResults.map((entry) => mapEntry(entry)).toList();
  }

  ResultEntry mapEntry(ResultEntryDto dto) {
    return ResultEntry(
      dto.teamName,
      dto.points,
      dto.amountWins,
      dto.amountDraws,
      dto.amountDefeats,
      dto.goals,
      dto.goalsConceded,
    );
  }
}
