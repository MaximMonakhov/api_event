import 'package:api_event/models/api_response.dart';
import 'package:api_event/models/event.dart';
import 'package:api_event/provider/provider.dart';
import 'package:flutter/widgets.dart';

class ApiEvent<T> extends Event<ApiResponse<T>> {
  final Provider provider = Provider();

  final String service;
  final HttpMethod httpMethod;
  final T Function(String body) parser;
  final bool auth;
  final bool saveAuthToken;

  ApiEvent(
      {@required this.service,
      @required this.httpMethod,
      @required this.parser,
      this.auth = false,
      this.saveAuthToken = false})
      : assert(service != null &&
            service.isNotEmpty &&
            httpMethod != null &&
            parser != null);

  @override
  void publish(ApiResponse<dynamic> event) {
    ApiResponse<T> response = ApiResponse<T>(event);
    subject.sink.add(response);
  }

  Future run({String params, String body, Map<String, String> headers}) async =>
      await provider.run(this, params, body, headers);
}

enum HttpMethod { GET, POST }
