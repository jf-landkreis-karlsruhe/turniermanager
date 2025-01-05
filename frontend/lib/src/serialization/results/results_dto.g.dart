// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'results_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResultsDto _$ResultsDtoFromJson(Map<String, dynamic> json) => ResultsDto(
      (json['matchRound'] as num).toInt(),
    )..leagueResults = (json['leagueResults'] as List<dynamic>)
        .map((e) => LeagueDto.fromJson(e as Map<String, dynamic>))
        .toList();

Map<String, dynamic> _$ResultsDtoToJson(ResultsDto instance) =>
    <String, dynamic>{
      'matchRound': instance.matchRound,
      'leagueResults': instance.leagueResults.map((e) => e.toJson()).toList(),
    };
