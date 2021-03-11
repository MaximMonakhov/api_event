import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:api_event/models/api_event.dart';
import 'package:api_event/models/api_response.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';

class Provider {
  static final Provider _provider = Provider._internal();
  factory Provider() {
    return _provider;
  }
  Provider._internal();

  final IOClient client = new IOClient();
  final Duration timeout = Duration(seconds: 10);

  String authToken;
  String url;

  void run(ApiEvent event) async {
    event.publish(ApiResponse.loading("Loading"));

    try {
      Response response;
      switch (event.httpMethod) {
        case HttpMethod.GET:
          response = await client
              .get(url + event.url + event.params ?? "",
                  headers: event.auth
                      ? {"Authorization": "Bearer " + authToken}
                      : {})
              .timeout(timeout);
          break;
        case HttpMethod.POST:
          response = await client
              .post(url + event.url,
                  body: event.body,
                  headers: event.auth
                      ? {"Authorization": "Bearer " + authToken}
                      : {})
              .timeout(timeout);
          break;
      }

      if (response.statusCode == 200) {
        final String body = utf8.decode(response.bodyBytes);
        final data = await compute(event.parser, body);
        event.publish(ApiResponse.completed(data));

        if (event.saveAuthToken) _setToken(response.headers["set-cookie"]);
        return;
      }

      throw Exception;
    } catch (exception) {
      ApiResponse errorApiResponse = await _onException(exception);
      event.publish(errorApiResponse);
      print("Ошибка во время выполнения provider.run(${event.url}): " +
          exception.toString());
    }
  }

  void _setToken(String cookie) {
    authToken = cookie.substring(cookie.indexOf("session_token=") + 14,
        cookie.indexOf(";", cookie.indexOf("session_token=")));
  }

  Future<ApiResponse> _onException(exception) async {
    bool internetStatus = await checkInternetConnection();

    return internetStatus
        ? exception.runtimeType == SocketException ||
                exception.runtimeType == TimeoutException
            ? ApiResponse.error('Сервис недоступен')
            : ApiResponse.error('Возникла внутренняя ошибка')
        : ApiResponse.error('Отсутствует интернет-соединение');
  }

  static Future<bool> checkInternetConnection() async {
    ConnectivityResult connectivityResult =
        await Connectivity().checkConnectivity();

    return connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi;
  }
}
