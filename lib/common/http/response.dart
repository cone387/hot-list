import 'package:dio/dio.dart' as dioRes;

class Response {
  late Uri url;
  late dioRes.Response _response;
  late int statusCode;
  String? error;
  // ignore: non_constant_identifier_names
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
