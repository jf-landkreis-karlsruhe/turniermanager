import 'package:tournament_manager/src/model/referee/age_group.dart';
import 'package:tournament_manager/src/serialization/referee/age_group_dto.dart';

class AgeGroupMapper {
  AgeGroup map(AgeGroupDto dto) {
    return AgeGroup(dto.name);
  }
}
