import 'package:flutter/services.dart';

abstract class ConfigService {
  Future<String> getBackendUrl();
}

class ConfigServiceImplementation implements ConfigService {
  String _backendUrl = 'localhost:8080';

  @override
  Future<String> getBackendUrl() async {
    try {
      _backendUrl =
          await rootBundle.loadString('assets/textfiles/backend-url.txt');
      return _backendUrl;
    } on Exception {
      return _backendUrl;
    }
  }
}
