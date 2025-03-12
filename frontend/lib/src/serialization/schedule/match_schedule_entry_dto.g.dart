// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_schedule_entry_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MatchScheduleEntryDto _$MatchScheduleEntryDtoFromJson(
        Map<String, dynamic> json) =>
    MatchScheduleEntryDto(
      json['pitchName'] as String,
      json['teamAName'] as String,
      json['teamBName'] as String,
      DateTime.parse(json['startTime'] as String),
    );

Map<String, dynamic> _$MatchScheduleEntryDtoToJson(
        MatchScheduleEntryDto instance) =>
    <String, dynamic>{
      'pitchName': instance.pitchName,
      'teamAName': instance.teamAName,
      'teamBName': instance.teamBName,
      'startTime': instance.startTime.toIso8601String(),
    };
