import 'dart:io';

import 'package:api_event/models/api_response.dart';
import 'package:api_event/models/event.dart';
import 'package:api_event/provider/provider.dart';
import 'package:flutter/widgets.dart';

class ApiEvent<T> extends Event<ApiResponse<T>> {
  final Provider provider = Provider();

  final String service;
  final HttpMethod httpMethod;
  final T Function(String body) parser;

  HttpClientResponse response;

  ApiEvent({@required this.service, @required this.httpMethod, this.parser}) : assert(service != null && service.isNotEmpty && httpMethod != null);

  @override
  void publish(ApiResponse<dynamic> event) {
    ApiResponse<T> response = ApiResponse<T>(event);
    subject.sink.add(response);
  }

  Future<ApiResponse<T>> run({String params, String body, Map<String, String> headers, List<Cookie> cookies}) async =>
      await provider.run(this, params, body, headers, cookies);
}

enum HttpMethod { GET, POST }
