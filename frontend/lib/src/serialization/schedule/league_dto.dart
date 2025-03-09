import 'package:tournament_manager/src/serialization/schedule/match_schedule_entry_dto.dart';
import 'package:json_annotation/json_annotation.dart';

// autogenerated with 'dart run build_runner build --delete-conflicting-outputs'
part 'league_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class LeagueDto {
  LeagueDto(this.leagueName);

  String leagueName;
  List<MatchScheduleEntryDto> entries = [];

  factory LeagueDto.fromJson(Map<String, dynamic> json) =>
      _$LeagueDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LeagueDtoToJson(this);
}
