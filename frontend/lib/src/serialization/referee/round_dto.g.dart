// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'round_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoundDto _$RoundDtoFromJson(Map<String, dynamic> json) => RoundDto(
      json['name'] as String,
    )..games = (json['games'] as List<dynamic>)
        .map((e) => GameDto.fromJson(e as Map<String, dynamic>))
        .toList();

Map<String, dynamic> _$RoundDtoToJson(RoundDto instance) => <String, dynamic>{
      'name': instance.name,
      'games': instance.games.map((e) => e.toJson()).toList(),
    };
