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

  Duration timeout = Duration(seconds: 10);
  IOClient client = new IOClient();
  String authToken;
  static String url;

  Future<dynamic> run(ApiEvent event, String params, String body,
      Map<String, String> headers) async {
    event.publish(ApiResponse.loading("Loading"));

    String url = (Provider.url ?? "") +
        event.service +
        (params != null ? "/" + params : "");

    try {
      Response response;

      Map<String, String> headersBuilder = {};

      headersBuilder.addAll(headers ?? {});
      headersBuilder
          .addAll(event.auth ? {"Authorization": "Bearer " + authToken} : {});

      switch (event.httpMethod) {
        case HttpMethod.GET:
          response = await client
              .get(Uri.parse(url), headers: headersBuilder)
              .timeout(timeout);
          break;
        case HttpMethod.POST:
          response = await client
              .post(Uri.parse(url), body: body, headers: headersBuilder)
              .timeout(timeout);
          break;
      }

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty && event.parser != null) {
          final String body = utf8.decode(response.bodyBytes);
          final data = await compute(event.parser, body);
          event.publish(ApiResponse.completed(data));
        } else
          event.publish(ApiResponse.completed(''));

        if (event.saveAuthToken) _setToken(response.headers["set-cookie"]);
      } else
        throw Exception("Bad status code");
    } catch (exception) {
      print("Exception on provider.run: " + exception.toString());
      ApiResponse errorApiResponse = await _onException(exception);
      event.publish(errorApiResponse);
    }

    return event.value;
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
    try {
      ConnectivityResult connectivityResult =
          await Connectivity().checkConnectivity();

      return connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi;
    } catch (exception) {
      return true;
    }
  }
}
