import 'package:tournament_manager/src/model/age_group.dart';
import 'package:tournament_manager/src/serialization/age_group_dto.dart';

class AgeGroupMapper {
  AgeGroup map(AgeGroupDto dto) {
    return AgeGroup(dto.id, dto.name);
  }
}
