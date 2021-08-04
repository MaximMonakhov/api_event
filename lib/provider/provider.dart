import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:api_event/models/api_event.dart';
import 'package:api_event/models/api_response.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class Provider {
  static final Provider _provider = Provider._internal();
  factory Provider() {
    return _provider;
  }
  Provider._internal();

  static String url;
  static Duration timeout = Duration(seconds: 10);
  static void Function(HttpClientResponse response, String body) onRequestDone;

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
          request = await httpClient.getUrl(uri);
          break;
        case HttpMethod.POST:
          request = await httpClient.postUrl(uri);
          break;
        case HttpMethod.PUT:
          request = await httpClient.putUrl(uri);
          break;
        case HttpMethod.DELETE:
          request = await httpClient.deleteUrl(uri);
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

      final completer = Completer<String>();
      final contents = StringBuffer();
      response.transform(utf8.decoder).listen((data) {
        contents.write(data);
      }, onDone: () => completer.complete(contents.toString()));

      String responseBody = await completer.future;

      if (onRequestDone != null) onRequestDone(response, responseBody);

      event.response = response;

      if (200 <= response.statusCode && response.statusCode <= 299) {
        if (responseBody.isNotEmpty) {
          if (event.parser != null) {
            final data = await compute(event.parser, responseBody);
            event.publish(ApiResponse.completed(data));
          } else
            event.publish(ApiResponse.completed(responseBody));
        } else
          event.publish(ApiResponse.completed("Empty Body"));
      } else
        throw Exception("Bad status code: " + response.statusCode.toString() + "\nBody: " + responseBody);
    } catch (exception) {
      print("Exception on provider.run\n" + exception.toString());
      ApiResponse errorApiResponse = await _onException(exception);
      event.publish(errorApiResponse);
    }

    return event.value;
  }

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
