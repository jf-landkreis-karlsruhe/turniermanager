// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'league_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeagueDto _$LeagueDtoFromJson(Map<String, dynamic> json) => LeagueDto(
      json['leagueName'] as String,
    )..teams = (json['teams'] as List<dynamic>)
        .map((e) => ResultEntryDto.fromJson(e as Map<String, dynamic>))
        .toList();

Map<String, dynamic> _$LeagueDtoToJson(LeagueDto instance) => <String, dynamic>{
      'leagueName': instance.leagueName,
      'teams': instance.teams.map((e) => e.toJson()).toList(),
    };
