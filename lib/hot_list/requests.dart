import 'package:dio/dio.dart';
import 'package:hot_list/common/entities/types.dart';
import 'package:hot_list/common/http/requests.dart';
import 'package:hot_list/hot_list/controllers/user.dart';

export 'package:hot_list/common/http/requests.dart' show Response;

class _UserRequests extends BaseRequests {
  @override
  Options getOptions(Json? headers) {
    headers ??= {};
    if (GlobalUser.token != null) {
      headers['Authorization'] = 'Jwt ${GlobalUser.token!}';
    }
    return Options(
      headers: headers,
      contentType: 'Application/Json',
      responseType: ResponseType.json,
    );
  }
}

// ignore: non_constant_identifier_names
var UserRequests = _UserRequests();
