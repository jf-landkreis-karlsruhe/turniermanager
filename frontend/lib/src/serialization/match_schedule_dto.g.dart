// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_schedule_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MatchScheduleDto _$MatchScheduleDtoFromJson(Map<String, dynamic> json) =>
    MatchScheduleDto(
      json['field'] as String,
      json['team1'] as String,
      (json['pointsTeam1'] as num).toInt(),
      json['team2'] as String,
      (json['pointsTeam2'] as num).toInt(),
      json['startTime'] as String,
    );

Map<String, dynamic> _$MatchScheduleDtoToJson(MatchScheduleDto instance) =>
    <String, dynamic>{
      'field': instance.field,
      'team1': instance.team1,
      'pointsTeam1': instance.pointsTeam1,
      'team2': instance.team2,
      'pointsTeam2': instance.pointsTeam2,
      'startTime': instance.startTime,
    };
