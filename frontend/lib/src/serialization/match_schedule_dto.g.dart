// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_schedule_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MatchScheduleDto _$MatchScheduleDtoFromJson(Map<String, dynamic> json) =>
    MatchScheduleDto()
      ..entries = (json['entries'] as List<dynamic>)
          .map((e) => MatchScheduleEntryDto.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$MatchScheduleDtoToJson(MatchScheduleDto instance) =>
    <String, dynamic>{
      'entries': instance.entries.map((e) => e.toJson()).toList(),
    };
