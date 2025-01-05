// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_schedule_entry_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MatchScheduleEntryDto _$MatchScheduleEntryDtoFromJson(
        Map<String, dynamic> json) =>
    MatchScheduleEntryDto(
      json['field'] as String,
      json['team1'] as String,
      json['team2'] as String,
      json['startTime'] as String,
    );

Map<String, dynamic> _$MatchScheduleEntryDtoToJson(
        MatchScheduleEntryDto instance) =>
    <String, dynamic>{
      'field': instance.field,
      'team1': instance.team1,
      'team2': instance.team2,
      'startTime': instance.startTime,
    };
