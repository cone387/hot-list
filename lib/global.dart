import 'package:flutter/material.dart';
import 'package:hot_list/common/entities/oauth.dart';
import 'package:hot_list/hot_list/controllers/subscribe.dart';
import 'package:hot_list/hot_list/controllers/user.dart';
import 'package:hot_list/logger.dart';
import 'common/http/requests.dart';

class Env {
  final String? name;
  final String ip;
  final int? port;
  final String? domain;
  final bool usingIp;
  const Env(
      {this.name,
      required this.ip,
      this.port = 8000,
      this.domain,
      this.usingIp: false});

  String get host {
    if (usingIp || domain == null) {
      if (port != null) {
        return "$ip:$port";
      }
      return ip;
    }
    assert(domain != null, "domain is required while usingIp is false");
    return domain!;
  }

  static const Env companySimulator = Env(ip: "127.0.0.1");
  static const Env debugRealMachine = Env(ip: "192.168.31.219");
  static const Env debugSimulator = Env(ip: "127.0.0.1");
  static const Env releaseIpTX = Env(ip: "42.192.130.234");
  static const Env releaseIpALY = Env(ip: "139.196.162.148");
  static const Env releaseDomainTX =
      Env(ip: "42.192.130.234", domain: "api.qiuyi.me");
  static const Env releaseDomainALY =
      Env(ip: "42.192.130.234", domain: "api.cone387.top");
}

Oauth dingdingTxRelease = const Oauth(
    name: '腾讯钉钉服务',
    url: 'http://42.192.130.234:8000',
    path: '/oauth/callback/dingding/',
    clientId: 'ding8njjiygeanfipdbu',
    oauthBaseUrl:
        'https://oapi.dingtalk.com/connect/oauth2/sns_authorize?appid={client_id}&response_type=code&scope=snsapi_login&state=STATE&redirect_uri={redirect_uri}');
Oauth dingdingAlyRelease = dingdingTxRelease.copyWith(
    name: '阿里云钉钉服务',
    url: 'https://cone387.top',
    clientId: 'ding8njjiygeanfipdbu');
Oauth dingdingDebug = dingdingTxRelease.copyWith(
    url: "http://localhost:8000",
    name: '钉钉本地',
    clientId: 'ding8njjiygeanfipdbu');

Oauth githubTxRelease = const Oauth(
    name: '腾讯Github服务',
    url: 'http://42.192.130.234:8000',
    path: '/oauth/callback/github/',
    clientId: '588827601c3b4b9fae99',
    oauthBaseUrl:
        "https://github.com/login/oauth/authorize?client_id={client_id}&state=1131314111&redirect_uri={redirect_uri}");

Oauth githubAlyRelease = githubTxRelease.copyWith(
    name: '阿里云Github服务',
    url: 'https://api.cone387.top',
    clientId: '588827601c3b4b9fae99');

Oauth githubDebug = githubTxRelease.copyWith(
    url: "http://localhost:8000",
    name: 'Github本地',
    clientId: 'a8c677d78cfdd1efa50c');

class Global {
  static bool isInitialized = false;
  static bool debug = true;
  static bool isSimulator = true;
  static String appName = 'HotList';
  // static Env env = Env.releaseDomainTX;
  static Env env = Env.debugSimulator;
  static String cdnHost = 'cdn.cone.love';
  static String cdnScheme = 'http';
  static String cdnBaseUrl = "$cdnScheme://$cdnHost";

  static String version = 'v1.0.0';

  static int pageIndex = 0;
  static String pageName = '';
  static String pageRoute = '';

  static GlobalKey<ScaffoldState>? drawerKey;

  // default user avatar
  static String defaultAvatar = 'assets/images/avatar.png';

  static Oauth oauthGithub = githubAlyRelease;
  static Oauth oauthDingDing = dingdingTxRelease;

  static GlobalKey<OverlayState> overlay = GlobalKey<OverlayState>();
  static OverlayState? overlayState;

  static Future init() async {
    await Requests.init(host: env.host, https: !debug);
    await UserController.isItemInitialized;
    await UserController.refreshItem();
    isInitialized = true;
  }
}

void onLoginChanged(bool isLogin) {
  logger.i("user login status changed to $isLogin");
  if (UserController.isLoggedIn.value != isLogin) {
    UserController.isLoggedIn.value = isLogin;
  }
}
