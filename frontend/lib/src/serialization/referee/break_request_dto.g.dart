// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'break_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BreakRequestDto _$BreakRequestDtoFromJson(Map<String, dynamic> json) =>
    BreakRequestDto(
      DateTime.parse(json['breakTime'] as String),
      (json['duration'] as num).toInt(),
    );

Map<String, dynamic> _$BreakRequestDtoToJson(BreakRequestDto instance) =>
    <String, dynamic>{
      'breakTime': instance.breakTime.toIso8601String(),
      'duration': instance.duration,
    };
