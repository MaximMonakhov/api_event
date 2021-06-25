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

  Duration timeout = Duration(seconds: 10);
  HttpClient httpClient = HttpClient();

  Future<dynamic> run(ApiEvent event, String params, String body, Map<String, String> headers, List<Cookie> cookies) async {
    event.publish(ApiResponse.loading("Loading"));

    String url = (Provider.url ?? "") + event.service + (params != null ? "/" + params : "");
    Uri uri = Uri.parse(url);

    try {
      HttpClientRequest request;

      Map<String, String> headersBuilder = {};

      headersBuilder.addAll(headers ?? {});

      if (cookies != null && cookies.isNotEmpty) {
        String rawCookies = cookies.map((Cookie cookie) => '${cookie.name}=${cookie.value}').join('; ');
        if (rawCookies != null && rawCookies.isNotEmpty) headersBuilder.addAll({"cookie": rawCookies});
      }

      headersBuilder.forEach((key, value) {
        request.headers.add(key, value);
      });

      switch (event.httpMethod) {
        case HttpMethod.GET:
          request = await httpClient.get(uri.host, uri.port, uri.path).timeout(timeout);
          break;
        case HttpMethod.POST:
          List<int> bodyBytes = utf8.encode(body);
          request.add(bodyBytes);
          request = await httpClient.post(uri.host, uri.port, uri.path).timeout(timeout);
          break;
      }

      HttpClientResponse response = await request.close();

      if (response.statusCode == 200) {
        event.cookies = response.cookies;

        final completer = Completer<String>();
        final contents = StringBuffer();
        response.transform(utf8.decoder).listen((data) {
          contents.write(data);
        }, onDone: () => completer.complete(contents.toString()));

        String body = await completer.future;

        if (body.isNotEmpty && event.parser != null) {
          final data = await compute(event.parser, body);
          event.publish(ApiResponse.completed(data));
        } else
          event.publish(ApiResponse.completed(body));
      } else
        throw Exception("Bad status code: " + response.statusCode.toString() + ". Body: " + body);
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
}
