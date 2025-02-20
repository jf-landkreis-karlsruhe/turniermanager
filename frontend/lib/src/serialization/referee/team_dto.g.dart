// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeamDto _$TeamDtoFromJson(Map<String, dynamic> json) => TeamDto(
      json['name'] as String,
      AgeGroupDto.fromJson(json['ageGroup'] as Map<String, dynamic>),
      LeagueDto.fromJson(json['league'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TeamDtoToJson(TeamDto instance) => <String, dynamic>{
      'name': instance.name,
      'ageGroup': instance.ageGroup.toJson(),
      'league': instance.league.toJson(),
    };
