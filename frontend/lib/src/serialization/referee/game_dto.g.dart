// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameDto _$GameDtoFromJson(Map<String, dynamic> json) => GameDto(
      (json['gameNumber'] as num).toInt(),
      PitchDto.fromJson(json['pitch'] as Map<String, dynamic>),
      TeamDto.fromJson(json['teamA'] as Map<String, dynamic>),
      TeamDto.fromJson(json['teamB'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GameDtoToJson(GameDto instance) => <String, dynamic>{
      'gameNumber': instance.gameNumber,
      'pitch': instance.pitch.toJson(),
      'teamA': instance.teamA.toJson(),
      'teamB': instance.teamB.toJson(),
    };
