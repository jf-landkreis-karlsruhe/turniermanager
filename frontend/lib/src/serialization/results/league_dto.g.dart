// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'league_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeagueDto _$LeagueDtoFromJson(Map<String, dynamic> json) => LeagueDto(
      (json['leagueNo'] as num).toInt(),
    )..gameResults = (json['gameResults'] as List<dynamic>)
        .map((e) => ResultEntryDto.fromJson(e as Map<String, dynamic>))
        .toList();

Map<String, dynamic> _$LeagueDtoToJson(LeagueDto instance) => <String, dynamic>{
      'leagueNo': instance.leagueNo,
      'gameResults': instance.gameResults.map((e) => e.toJson()).toList(),
    };
