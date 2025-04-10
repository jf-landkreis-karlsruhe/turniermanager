import 'package:json_annotation/json_annotation.dart';

// autogenerated with 'dart run build_runner build --delete-conflicting-outputs'
part 'break_request_dto.g.dart';

@JsonSerializable()
class BreakRequestDto {
  BreakRequestDto(
    this.breakTime,
    this.duration,
  );

  DateTime breakTime;
  int duration;

  factory BreakRequestDto.fromJson(Map<String, dynamic> json) =>
      _$BreakRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BreakRequestDtoToJson(this);
}
