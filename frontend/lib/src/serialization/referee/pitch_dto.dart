import 'package:json_annotation/json_annotation.dart';

// autogenerated with 'dart run build_runner build --delete-conflicting-outputs'
part 'pitch_dto.g.dart';

@JsonSerializable()
class PitchDto {
  PitchDto(
    this.id,
    this.name,
  );

  String id;
  String name;

  factory PitchDto.fromJson(Map<String, dynamic> json) =>
      _$PitchDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PitchDtoToJson(this);
}
