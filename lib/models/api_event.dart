import 'package:api_event/models/api_response.dart';
import 'package:api_event/models/event.dart';
import 'package:api_event/provider/provider.dart';
import 'package:flutter/widgets.dart';

class ApiEvent<T> extends Event<ApiResponse<T>> {
  final Provider provider = Provider();

  final String url;
  final HttpMethod httpMethod;
  final T Function(dynamic body) responseBodyParser;
  final bool auth;
  final bool saveAuthToken;

  String body;

  ApiEvent(
      {@required this.url,
      @required this.httpMethod,
      @required this.responseBodyParser,
      this.auth = false,
      this.saveAuthToken = false});

  void run() {
    provider.run(this);
    body = null;
  }

  @override
  void publish(ApiResponse<dynamic> event) {
    ApiResponse<T> response = ApiResponse<T>(event);
    subject.sink.add(response);
  }

  T parse(dynamic body) => responseBodyParser(body);
}

enum HttpMethod { GET, POST }
