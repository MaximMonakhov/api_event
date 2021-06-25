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
  static String url;

  Future<dynamic> run(ApiEvent event, String params, String body, Map<String, String> headers, List<Cookie> cookies) async {
    event.publish(ApiResponse.loading("Loading"));

    String url = (Provider.url ?? "") + event.service + (params != null ? "/" + params : "");

    try {
      Response response;

      Map<String, String> headersBuilder = {};

      headersBuilder.addAll(headers ?? {});

      if (cookies != null && cookies.isNotEmpty) {
        String rawCookies = cookies.map((Cookie cookie) => '${cookie.name}=${cookie.value}').join('; ');
        if (rawCookies != null && rawCookies.isNotEmpty) headersBuilder.addAll({"cookie": rawCookies});
      }

      switch (event.httpMethod) {
        case HttpMethod.GET:
          response = await client.get(Uri.parse(url), headers: headersBuilder).timeout(timeout);
          break;
        case HttpMethod.POST:
          response = await client.post(Uri.parse(url), body: body, headers: headersBuilder).timeout(timeout);
          break;
      }

      if (response.statusCode == 200) {
        List<Cookie> cookies = parseCookie(response.headers["Set-Cookie"]);
        event.cookies = cookies;

        final String body = utf8.decode(response.bodyBytes);

        if (response.body.isNotEmpty && event.parser != null) {
          final data = await compute(event.parser, body);
          event.publish(ApiResponse.completed(data));
        } else
          event.publish(ApiResponse.completed(body));
      } else
        throw Exception("Bad status code: " + response.statusCode.toString() + ". Body: " + utf8.decode(response.bodyBytes));
    } catch (exception) {
      print("Exception on provider.run: " + exception.toString());
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

  List<Cookie> parseCookie(String rawCookies) {
    if (rawCookies == null) return null;

    List<Cookie> cookies = [];
    List<String> pairs = rawCookies.replaceAll(" ", "").split(",");

    for (String pair in pairs) cookies.add(Cookie.fromSetCookieValue(pair));

    return cookies;
  }
}
