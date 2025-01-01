// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_schedule_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MatchScheduleDto _$MatchScheduleDtoFromJson(Map<String, dynamic> json) =>
    MatchScheduleDto()
      ..leagueSchedules = (json['leagueSchedules'] as List<dynamic>)
          .map((e) => LeagueDto.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$MatchScheduleDtoToJson(MatchScheduleDto instance) =>
    <String, dynamic>{
      'leagueSchedules':
          instance.leagueSchedules.map((e) => e.toJson()).toList(),
    };
