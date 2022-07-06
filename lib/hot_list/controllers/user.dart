// ignore_for_file: non_constant_identifier_names, library_private_types_in_public_api

import 'package:get/get.dart';
import 'package:hot_list/common/controllers/object.dart';
import 'package:hot_list/common/entities/types.dart';
import 'package:hot_list/common/http/requests.dart';
import 'package:hot_list/global.dart';
import 'package:hot_list/hot_list/api.dart';
import 'package:hot_list/hot_list/entities/user.dart';
import 'package:hot_list/hot_list/requests.dart';

class _UserController extends HttpCacheableRichItemController<UserEntity> {
  late RxBool isLoggedIn = false.obs;

  Future<String?> login() async {
    var response = await UserRequests.post(API.login, body: {
      'username': GlobalUser.username,
      'password': GlobalUser.password,
    });
    // 成功则返回空，否则返回错误信息
    if (!response.OK) {
      return getError(response.getJson());
    }
    return null;
  }

  onLoginSucceed(Json json) {
    item.value.update(UserEntity.fromJson(json));
    toCache(item.value);
    onLoginChanged(true);
  }

  onLoginFailed() {
    item.value = UserEntity();
    onLoginChanged(false);
  }

  Future logout() async {
    onLoginFailed();
  }

  @override
  Future<UserEntity?> getItem() async {
    var o = await super.getItem();
    if (o != null) {
      o.token ??= item.value.token;
      onLoginChanged(true);
    } else {
      o = initItem;
    }
    return o;
  }

  @override
  BaseRequests get requests => UserRequests;

  @override
  UserEntity decoder(Json json) => UserEntity.fromJson(json);

  @override
  String get updateUrl => API.profileUpdate;

  @override
  UserEntity get initItem => UserEntity();

  @override
  String get getUrl => API.profileGet;

  @override
  String get key => "cache-use-info";

}

_UserController UserController = _UserController();
UserEntity get GlobalUser => UserController.item.value;
