// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_group_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameGroupDto _$GameGroupDtoFromJson(Map<String, dynamic> json) => GameGroupDto(
      DateTime.parse(json['startTime'] as String),
    )..games = (json['games'] as List<dynamic>)
        .map((e) => GameDto.fromJson(e as Map<String, dynamic>))
        .toList();

Map<String, dynamic> _$GameGroupDtoToJson(GameGroupDto instance) =>
    <String, dynamic>{
      'startTime': instance.startTime.toIso8601String(),
      'games': instance.games.map((e) => e.toJson()).toList(),
    };
