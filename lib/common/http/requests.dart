import 'dart:io';
import 'package:flutter/foundation.dart';

import '../logger.dart';
import 'package:dio/dio.dart';
import 'response.dart' as response;
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hot_list/common/entities/types.dart';
export 'response.dart';

class BaseRequests {
  late var cj;
  static String? _host;
  bool _https = true;

  static BaseOptions options = BaseOptions(
    // baseUrl: Global.host,
    connectTimeout: 20000,
    receiveTimeout: 20000,
  );

  Dio dio = Dio(options);

  setHost(String host) {
    _host = host;
  }

  String? getHost() {
    return _host;
  }

  bool get isHttps {
    return _https;
  }

  // static final BaseRequests _instance = BaseRequests._internal();
  // factory BaseRequests({String? host}){
  //     if(host != null){_instance.setHost(host);}
  //     return _instance;
  // }

  // BaseRequests._internal(){
  //     dio = new Dio(options);
  // }

  init({host, https: true}) async {
    // Requests.host = host;
    _host = host;
    _https = https;
    if (!kIsWeb) {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      var appDocPath = appDocDir.path;
      cj = PersistCookieJar(
          ignoreExpires: true, storage: FileStorage(appDocPath));
      dio.interceptors.add(CookieManager(cj));
    }
  }

  Uri getUri(String path, {String? host, bool? https, params}) {
    if (path.startsWith('http')) {
      return Uri.parse(path);
    }
    host ??= _host;
    assert(host != null, "host cant be null");
    https = https ?? _https;
    if (https) {
      return Uri.https(host!, path, params);
    } else {
      return Uri.http(host!, path, params);
    }
  }

  Future<response.Response> get(path,
      {bool? https, String? host, Json? params, Json? headers}) async {
    var url = Requests.getUri(path, host: host, https: https, params: params);
    logger.d("start get $url");
    Response dioResponse;
    try {
      dioResponse = await dio.getUri(url, options: getOptions(headers));
    } on DioError catch (e) {
      logger.e("exception on get $url, status: ${e.response?.statusCode}");
      dioResponse = e.response ?? response.NETWORK_ERROR_RESPONSE;
    } catch (e) {
      logger.e(
          "exception on get $url, status: ${response.REQUEST_ERROR_RESPONSE.statusCode}");
      dioResponse = response.REQUEST_ERROR_RESPONSE;
    }
    logger.d("end get $url");
    return response.Response(dioResponse);
  }

  Future<response.Response> post(path,
      {String? host, bool? https, dynamic body, Json? headers}) async {
    var url = Requests.getUri(path, https: https, host: host);
    logger.d("start post $url");
    Response dioResponse;
    try {
      dioResponse =
          await dio.postUri(url, data: body, options: getOptions(headers));
    } on DioError catch (e) {
      logger.e("exception on get $url, status: ${e.response?.statusCode}");
      dioResponse = e.response ?? response.NETWORK_ERROR_RESPONSE;
    } catch (e) {
      logger.e(
          "exception on get $url, status: ${response.REQUEST_ERROR_RESPONSE.statusCode}");
      dioResponse = response.REQUEST_ERROR_RESPONSE;
    }
    logger.d("end post $url");
    return response.Response(dioResponse);
  }

  Future<response.Response> put(path,
      {String? host, bool? https, dynamic body, Json? headers}) async {
    var url = Requests.getUri(path, https: https, host: host);
    logger.d("start put $url");
    Response dioResponse;
    try {
      dioResponse =
          await dio.putUri(url, data: body, options: getOptions(headers));
    } on DioError catch (e) {
      logger.e("exception on get $url, status: ${e.response?.statusCode}");
      dioResponse = e.response ?? response.NETWORK_ERROR_RESPONSE;
    } catch (e) {
      logger.e(
          "exception on get $url, status: ${response.REQUEST_ERROR_RESPONSE.statusCode}");
      dioResponse = response.REQUEST_ERROR_RESPONSE;
    }
    logger.d("end put $url");
    return response.Response(dioResponse);
  }

  Future<response.Response> patch(path,
      {String? host, bool? https, dynamic body, Json? headers}) async {
    var url = Requests.getUri(path, https: https, host: host);
    logger.d("start put $url");
    Response dioResponse;
    try {
      dioResponse =
          await dio.patchUri(url, data: body, options: getOptions(headers));
    } on DioError catch (e) {
      logger.e("exception on get $url, status: ${e.response?.statusCode}");
      dioResponse = e.response ?? response.NETWORK_ERROR_RESPONSE;
    } catch (e) {
      logger.e(
          "exception on get $url, status: ${response.REQUEST_ERROR_RESPONSE.statusCode}");
      dioResponse = response.REQUEST_ERROR_RESPONSE;
    }
    logger.d("end put $url");
    return response.Response(dioResponse);
  }

  Future<response.Response> delete(path,
      {String? host, bool? https, Json? headers}) async {
    var url = Requests.getUri(path, https: https, host: host);
    Response dioResponse;
    try {
      dioResponse = await dio.deleteUri(url, options: getOptions(headers));
    } on DioError catch (e) {
      logger.e("exception on get $url, status: ${e.response?.statusCode}");
      dioResponse = e.response ?? response.NETWORK_ERROR_RESPONSE;
    } catch (e) {
      logger.e(
          "exception on get $url, status: ${response.REQUEST_ERROR_RESPONSE.statusCode}");
      dioResponse = response.REQUEST_ERROR_RESPONSE;
    }
    logger.d("end delete $url");
    return response.Response(dioResponse);
  }

  Options getOptions(Json? headers) {
    return Options(
      headers: headers,
      contentType: 'Application/Json',
      responseType: ResponseType.json,
    );
  }
}

// ignore: non_constant_identifier_names
BaseRequests Requests = BaseRequests();
