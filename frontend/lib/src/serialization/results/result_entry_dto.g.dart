// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result_entry_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResultEntryDto _$ResultEntryDtoFromJson(Map<String, dynamic> json) =>
    ResultEntryDto(
      json['teamName'] as String,
      (json['totalPoints'] as num).toInt(),
      (json['victories'] as num).toInt(),
      (json['draws'] as num).toInt(),
      (json['defeats'] as num).toInt(),
      (json['ownScoredGoals'] as num).toInt(),
      (json['enemyScoredGoals'] as num).toInt(),
    );

Map<String, dynamic> _$ResultEntryDtoToJson(ResultEntryDto instance) =>
    <String, dynamic>{
      'teamName': instance.teamName,
      'totalPoints': instance.totalPoints,
      'victories': instance.victories,
      'draws': instance.draws,
      'defeats': instance.defeats,
      'ownScoredGoals': instance.ownScoredGoals,
      'enemyScoredGoals': instance.enemyScoredGoals,
    };
