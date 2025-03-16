import 'package:flutter/material.dart';
import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;

abstract class RestClient {
  @protected
  final http.Client client = BrowserClient();
  @protected
  final headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Access-Control-Allow-Origin': '*'
  };

  @protected
  final String baseUri = '127.0.0.1:8080';
}
