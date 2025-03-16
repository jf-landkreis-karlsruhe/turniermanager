// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timing_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimingRequestDto _$TimingRequestDtoFromJson(Map<String, dynamic> json) =>
    TimingRequestDto(
      DateTime.parse(json['startTime'] as String),
      DateTime.parse(json['actualStartTime'] as String),
      DateTime.parse(json['endTime'] as String),
    );

Map<String, dynamic> _$TimingRequestDtoToJson(TimingRequestDto instance) =>
    <String, dynamic>{
      'startTime': instance.startTime.toIso8601String(),
      'actualStartTime': instance.actualStartTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
    };
