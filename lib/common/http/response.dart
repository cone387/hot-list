// ignore_for_file: non_constant_identifier_names

import 'package:dio/dio.dart' as dioRes;


dioRes.Response NETWORK_ERROR_RESPONSE =
    dioRes.Response(
      statusCode: 600,
      statusMessage: '网络异常',
      requestOptions: dioRes.RequestOptions(path: '/'));

dioRes.Response REQUEST_ERROR_RESPONSE =
    dioRes.Response(
      statusCode: 700,
      statusMessage: '请求有异常',
      requestOptions: dioRes.RequestOptions(path: '/'));


class Response {
  late Uri url;
  late dioRes.Response _response;
  late int statusCode;
  String? error;
  late bool OK;
  late bool isAuth;
  static int created = 201;
  static int deleted = 204;
  String? _text;

  Response(dioRes.Response response) {
    _response = response;
    statusCode = response.statusCode ?? 500;
    // url = _response.request.url;
    url = response.realUri;
    OK = statusCode >= 200 && statusCode <= 210;
    isAuth = statusCode < 400;
  }

  bool get isCreated => statusCode == 201;
  bool get isDeleted => statusCode == 204;
  bool get isOK => statusCode >= 200 && statusCode <= 210;

  String getText() {
    _text ??= _response.data.toString();
    return _text!;
  }

  dynamic getJson() {
    return _response.data;
    // return getText();
    // return json.decode(getText());
  }
}
