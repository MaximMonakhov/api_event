import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:api_event/models/api_event.dart';
import 'package:api_event/models/api_response.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';

class Provider {
  static final Provider _provider = Provider._internal();
  factory Provider() {
    return _provider;
  }
  Provider._internal();

  static String url;
  static Duration timeout = Duration(seconds: 10);
  static void Function(HttpClientResponse response) onRequestDone;

  Future<dynamic> run(ApiEvent event, String params, String body, Map<String, String> headers, List<Cookie> cookies) async {
    event.publish(ApiResponse.loading("Loading"));

    HttpClient httpClient = HttpClient();
    httpClient.connectionTimeout = timeout;

    try {
      String url = (Provider.url ?? "") + event.service + (params != null ? "/" + params : "");
      Uri uri = Uri.parse(url);

      HttpClientRequest request;

      switch (event.httpMethod) {
        case HttpMethod.GET:
          request = await httpClient.get(uri.host, uri.port, uri.path);
          break;
        case HttpMethod.POST:
          request = await httpClient.post(uri.host, uri.port, uri.path);
          break;
      }

      Map<String, String> headersBuilder = {};

      headersBuilder.addAll(headers ?? {});

      if (cookies != null && cookies.isNotEmpty) headersBuilder.addAll({"cookie": cookies.map((Cookie cookie) => '${cookie.name}=${cookie.value}').join('; ')});

      headersBuilder.forEach((key, value) {
        request.headers.add(key, value);
      });

      if (body != null && body.isNotEmpty) {
        List<int> bodyBytes = utf8.encode(body);
        request.add(bodyBytes);
      }

      HttpClientResponse response = await request.close();

      if (onRequestDone != null) onRequestDone(response);

      event.response = response;

      if (response.statusCode == 200) {
        final completer = Completer<String>();
        final contents = StringBuffer();
        response.transform(utf8.decoder).listen((data) {
          contents.write(data);
        }, onDone: () => completer.complete(contents.toString()));

        String body = await completer.future;

        if (body.isNotEmpty) {
          if (event.parser != null) {
            final data = await compute(event.parser, body);
            event.publish(ApiResponse.completed(data));
          } else
            event.publish(ApiResponse.completed(body));
        } else
          event.publish(ApiResponse.completed("Empty Body"));
      } else
        throw Exception("Bad status code: " + response.statusCode.toString() + "\nBody: " + body);
    } catch (exception) {
      print("Exception on provider.run\n" + exception.toString());
      ApiResponse errorApiResponse = await _onException(exception);
      event.publish(errorApiResponse);
    }

    return event.value;
  }

  Map<String, String> _buildHeaders() {}

  Future<ApiResponse> _onException(exception) async {
    bool internetStatus = await checkInternetConnection();

    return internetStatus
        ? exception.runtimeType == SocketException || exception.runtimeType == TimeoutException
            ? ApiResponse.error('Сервис недоступен')
            : ApiResponse.error('Возникла внутренняя ошибка')
        : ApiResponse.error('Отсутствует интернет-соединение');
  }

  static Future<bool> checkInternetConnection() async {
    try {
      ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();

      return connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi;
    } catch (exception) {
      return true;
    }
  }
}
