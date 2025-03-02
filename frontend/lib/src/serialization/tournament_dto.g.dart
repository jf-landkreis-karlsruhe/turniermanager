// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TournamentDto _$TournamentDtoFromJson(Map<String, dynamic> json) =>
    TournamentDto(
      (json['id'] as num).toInt(),
    )..ageGroups = (json['ageGroups'] as List<dynamic>)
        .map((e) => (e as num).toInt())
        .toList();

Map<String, dynamic> _$TournamentDtoToJson(TournamentDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ageGroups': instance.ageGroups,
    };
