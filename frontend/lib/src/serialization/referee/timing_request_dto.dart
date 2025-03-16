import 'package:json_annotation/json_annotation.dart';

// autogenerated with 'dart run build_runner build --delete-conflicting-outputs'
part 'timing_request_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class TimingRequestDto {
  TimingRequestDto(
    this.startTime,
    this.actualStartTime,
    this.endTime,
  );

  DateTime startTime;
  DateTime actualStartTime;
  DateTime endTime;

  factory TimingRequestDto.fromJson(Map<String, dynamic> json) =>
      _$TimingRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TimingRequestDtoToJson(this);
}
