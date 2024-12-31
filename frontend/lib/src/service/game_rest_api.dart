import 'dart:convert';

import 'package:tournament_manager/src/service/rest_client.dart';

abstract class GameRestApi {
  Future<String> getGameData(); //TODO: correct return value
}

class GameRestApiImplementation extends RestClient implements GameRestApi {
  late final Uri getGameDataUri;

  GameRestApiImplementation() {
    getGameDataUri = Uri.parse('$baseUri/getGameData'); //TODO: correct endpoint
  }

  @override
  Future<String> getGameData() async {
    final uri = getGameDataUri.replace(
        queryParameters: {'paramName': 'paramValue'}); //TODO: correct values

    final response = await client.get(uri, headers: headers);

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      //TODO: deserialize
      return 'success';
    }

    return 'error';
  }
}
