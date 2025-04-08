import 'package:json_annotation/json_annotation.dart';
import 'package:tournament_manager/src/serialization/referee/game_settings_dto.dart';

// autogenerated with 'dart run build_runner build --delete-conflicting-outputs'
part 'round_settings_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class RoundSettingsDto {
  RoundSettingsDto(this.gameSettings);

  Map<String, int> numberPerRounds = {};
  GameSettingsDto gameSettings;

  factory RoundSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$RoundSettingsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RoundSettingsDtoToJson(this);
}
