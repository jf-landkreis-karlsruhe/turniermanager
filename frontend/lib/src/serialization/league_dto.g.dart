// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'league_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeagueDto _$LeagueDtoFromJson(Map<String, dynamic> json) => LeagueDto(
      (json['leagueNo'] as num).toInt(),
    )..entries = (json['entries'] as List<dynamic>)
        .map((e) => MatchScheduleEntryDto.fromJson(e as Map<String, dynamic>))
        .toList();

Map<String, dynamic> _$LeagueDtoToJson(LeagueDto instance) => <String, dynamic>{
      'leagueNo': instance.leagueNo,
      'entries': instance.entries.map((e) => e.toJson()).toList(),
    };
