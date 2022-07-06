import 'package:hot_list/common/entities/types.dart';

class LoginResponse {
  Json? result;
  dynamic errorData;
  late bool success;

  LoginResponse.fromJson(Json json) {
    result = json['result'];
    errorData = json['error_data'];
    success = json['success'];
  }
}
