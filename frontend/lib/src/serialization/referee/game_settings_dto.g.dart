// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_settings_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameSettingsDto _$GameSettingsDtoFromJson(Map<String, dynamic> json) =>
    GameSettingsDto(
      DateTime.parse(json['startTime'] as String),
      (json['breakTime'] as num).toInt(),
      (json['playTime'] as num).toInt(),
    );

Map<String, dynamic> _$GameSettingsDtoToJson(GameSettingsDto instance) =>
    <String, dynamic>{
      'startTime': instance.startTime.toIso8601String(),
      'breakTime': instance.breakTime,
      'playTime': instance.playTime,
    };
