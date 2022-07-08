import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hot_list/global.dart';
import 'package:hot_list/hot_list/widgets/login.dart';
import 'package:hot_list/route.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LoginWidget(
      loginProviders: [
        LoginProvider(
            image: 'assets/images/oauth/github.png',
            name: 'GITHUB登录',
            oauth: Global.oauthGithub,
            onLoginSuccess: (json) {
              // DateTodoController().setDate(DateTime.now(), refresh: true);
              // Get.offAllNamed(Routes.home);
              Get.offAllNamed(Routes.home);
            }),
        LoginProvider(
            name: "钉钉登录",
            image: "assets/images/oauth/dingding.jpeg",
            oauth: Global.oauthDingDing,
            onLoginSuccess: (json) {
              // DateTodoController().setDate(DateTime.now(), refresh: true);
              // Get.offAllNamed(Routes.home);
              Get.offAllNamed(Routes.home);
            })
      ],
    );
  }
}
