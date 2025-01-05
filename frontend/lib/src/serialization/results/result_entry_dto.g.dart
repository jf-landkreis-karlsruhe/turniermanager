// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result_entry_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResultEntryDto _$ResultEntryDtoFromJson(Map<String, dynamic> json) =>
    ResultEntryDto(
      json['teamName'] as String,
      (json['points'] as num).toInt(),
      (json['amountWins'] as num).toInt(),
      (json['amountDraws'] as num).toInt(),
      (json['amountDefeats'] as num).toInt(),
      (json['goals'] as num).toInt(),
      (json['goalsConceded'] as num).toInt(),
    );

Map<String, dynamic> _$ResultEntryDtoToJson(ResultEntryDto instance) =>
    <String, dynamic>{
      'teamName': instance.teamName,
      'points': instance.points,
      'amountWins': instance.amountWins,
      'amountDraws': instance.amountDraws,
      'amountDefeats': instance.amountDefeats,
      'goals': instance.goals,
      'goalsConceded': instance.goalsConceded,
    };
