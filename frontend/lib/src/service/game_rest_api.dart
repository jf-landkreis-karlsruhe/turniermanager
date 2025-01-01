import 'dart:convert';
import 'package:tournament_manager/src/serialization/match_schedule_dto.dart';
import 'package:tournament_manager/src/service/rest_client.dart';

abstract class GameRestApi {
  Future<MatchScheduleDto?> getSchedule(String ageGroup, String league);
}

class GameRestApiImplementation extends RestClient implements GameRestApi {
  late final Uri getScheduleUri;

  GameRestApiImplementation() {
    getScheduleUri = Uri.parse('$baseUri/schedule');
  }

  @override
  Future<MatchScheduleDto?> getSchedule(String ageGroup, String league) async {
    final uri = getScheduleUri.replace(
      queryParameters: {
        'ageGroup': ageGroup,
        'league': league,
      },
    );

    final response = await client.get(uri, headers: headers);

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      return MatchScheduleDto.fromJson(json);
    }

    return null;
  }
}
