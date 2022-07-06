import 'package:hot_list/common/commont.dart';
import 'package:hot_list/common/utils/url.dart';
import 'package:hot_list/global.dart';
import 'package:hot_list/hot_list/controllers/subscribe.dart';
import 'package:hot_list/hot_list/entities/subscribe.dart';

class UserEntity extends IdSerializable {
  static String localKey = 'user.info';

  String username = "用户";
  String? email;
  String? token;
  String? image;
  String? password; // = '5f19a78bd283918a';
  String? platformId;
  List<UserSubscribe> subscribes = [];

  String? get avatarUrl {
    return image == null ? null : urlJoin(Global.cdnBaseUrl, image!);
  }

  UserEntity();

  update(UserEntity user) {
    id = user.id;
    username = user.username;
    email = user.email ?? email;
    token = user.token ?? token;
    platformId = user.platformId ?? platformId;
  }

  UserEntity.fromJson(Json json) {
    // id = json['id'];
    username = json['username'];
    email = json['email'];
    token = json['token'];
    image = json['image'];
    List subs = json['subscribes'] ?? [];
    subscribes = subs.map((e) => UserSubscribe.fromJson(e)).toList();
    platformId = json['platform_id'];
  }

  UserEntity copy() {
    return UserEntity.fromJson(toJson());
  }

  @override
  Json toJson() {
    return {
      // 'id': id,
      'platform_id': platformId,
      'username': username,
      'password': password,
      'token': token,
      'image': image,
      'email': email,
      'subscribes': subscribes
    };
  }

  @override
  String toString() {
    return "User(name=$username, email=$email, token=$token)";
  }

}
