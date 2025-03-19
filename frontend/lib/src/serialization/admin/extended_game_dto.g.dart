// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extended_game_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExtendedGameDto _$ExtendedGameDtoFromJson(Map<String, dynamic> json) =>
    ExtendedGameDto(
      (json['gameNumber'] as num).toInt(),
      json['pitch'] as String,
      json['teamA'] as String,
      json['teamB'] as String,
      json['leagueName'] as String,
      json['ageGroupName'] as String,
      (json['pointsTeamA'] as num).toInt(),
      (json['pointsTeamB'] as num).toInt(),
    );

Map<String, dynamic> _$ExtendedGameDtoToJson(ExtendedGameDto instance) =>
    <String, dynamic>{
      'gameNumber': instance.gameNumber,
      'pitch': instance.pitch,
      'teamA': instance.teamA,
      'teamB': instance.teamB,
      'leagueName': instance.leagueName,
      'ageGroupName': instance.ageGroupName,
      'pointsTeamA': instance.pointsTeamA,
      'pointsTeamB': instance.pointsTeamB,
    };
